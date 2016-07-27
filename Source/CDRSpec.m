#import <objc/runtime.h>

#import "CDRSpec.h"
#import "CDRExample.h"
#import "CDRRunState.h"
#import "CDRSpecHelper.h"
#import "CDRSpecFailure.h"
#import "CDRExampleGroup.h"
#import "CDRSymbolicator.h"

#define with_stack_address(b) \
((b.stackAddress = CDRCallerStackAddress()), b)

CDRSpec *CDR_currentSpec;

#pragma mark - Spec Validation

// runs validation when it(), context(), describe() are invoked
// generally this is a useful feature, but you may disable it if you
// care to do metaprogramming with Cedar specs
// (or other usecases we couldn't imagine).
BOOL CDR_validateSpecs = YES;

void CDRDisableSpecValidation() {
    CDR_validateSpecs = NO;
}

void CDREnableSpecValidation() {
    CDR_validateSpecs = YES;
}

#pragma mark - static vars

static void(^placeholderPendingTestBlock)() = ^{
    BOOL originalState = CDR_validateSpecs;
    CDR_validateSpecs = NO;

    it(@"is pending", PENDING);

    CDR_validateSpecs = originalState;
};

#pragma mark - public API
void beforeEach(CDRSpecBlock block) {
    [CDR_currentSpec.currentGroup addBefore:block];
}

void afterEach(CDRSpecBlock block) {
    [CDR_currentSpec.currentGroup addAfter:block];
}

void ensureCurrentSpecExists(NSString *functionName) {
    if (!CDR_validateSpecs) {
        return;
    }

    if (CDR_currentSpec == nil) {
        NSString * reason = [NSString stringWithFormat:@"%@() was invoked outside of a spec. It may only be called when a spec has been defined with SPEC_BEGIN and SPEC_END macros.", functionName];
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:reason
                               userInfo:nil] raise];
    }
}

void ensureTestsAreNotYetRunning(NSString *functionName) {
    if (!CDR_validateSpecs) {
        return;
    }

    switch (CDRCurrentState()) {
        case CedarRunStateNotYetStarted:
            // exceedingly unlikely
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                    reason:@"%@() was invoked BEFORE cedar started running at all. It's unclear how this happened, but this probably represents a bug in your tests. (Please consider opening a github issue if you're fairly certain your test setup is correct)"
                                   userInfo:nil] raise];
            break;
        case CedarRunStatePreparingTests:
            // happy path, no-op, we should hit this branch 100% of the time
            break;
        case CedarRunStateRunningTests: {
            // someone done goofed
            NSString * reason = [NSString stringWithFormat:@"%@() was invoked during a test run. Make sure your '%@()' is not inside of an it() block.", functionName, functionName];
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:reason
                                   userInfo:nil] raise];
            break;
        }
        case CedarRunStateFinished:
            // someone ... REALLY done goofed
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:@"%@() was invoked AFTER cedar finished running all its tests. It's unclear how this happened, but this probably represents a bug in your tests. (Please consider opening a github issue if you're fairly certain your test setup is correct)"
                                   userInfo:nil] raise];
            break;
    }
}

CDRExampleGroup *groupFromSpecBlock(NSString *text, CDRSpecBlock block) {
    if (!block) {
        return groupFromSpecBlock(text, placeholderPendingTestBlock);
    }

    CDRExampleGroup *parentGroup = CDR_currentSpec.currentGroup;
    CDRExampleGroup *group = [CDRExampleGroup groupWithText:text];
    [parentGroup add:group];
    CDR_currentSpec.currentGroup = group;

    @try {
        block();
    }
    @catch (CDRSpecFailure *failure) {
        NSString *reason = [NSString stringWithFormat:@"Caught a spec failure before the specs began to run. Did you forget to put your assertion into an `it` block?. The failure was:\n%@", failure];
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil] raise];
    }

    if ([group.examples count] == 0) {
        block = placeholderPendingTestBlock;
        block();
    }
    CDR_currentSpec.currentGroup = parentGroup;

    return group;
}

CDRExampleGroup * describe(NSString *text, CDRSpecBlock block) {
    ensureCurrentSpecExists(@"describe");
    ensureTestsAreNotYetRunning(@"describe");

    CDRExampleGroup *group = groupFromSpecBlock(text, block);
    return with_stack_address(group);
}

CDRExampleGroup* context(NSString *text, CDRSpecBlock block) {
    ensureCurrentSpecExists(@"context");
    ensureTestsAreNotYetRunning(@"context");

    CDRExampleGroup *group = groupFromSpecBlock(text, block);
    return with_stack_address(group);
}

void subjectAction(CDRSpecBlock block) {
    CDR_currentSpec.currentGroup.subjectActionBlock = block;
}

CDRExample * it(NSString *text, CDRSpecBlock block) {
    ensureCurrentSpecExists(@"it");
    ensureTestsAreNotYetRunning(@"it");

    CDRExample *example = [CDRExample exampleWithText:text andBlock:block];
    [CDR_currentSpec.currentGroup add:example];
    return with_stack_address(example);
}

#pragma mark - Pending

CDRExampleGroup * xdescribe(NSString *text, CDRSpecBlock block) {
    CDRExampleGroup *group = describe(text, placeholderPendingTestBlock);
    return with_stack_address(group);
}

CDRExampleGroup * xcontext(NSString *text, CDRSpecBlock block) {
    CDRExampleGroup *group = context(text, placeholderPendingTestBlock);
    return with_stack_address(group);
}

CDRExample * xit(NSString *text, CDRSpecBlock block) {
    CDRExample *example = it(text, PENDING);
    return with_stack_address(example);
}

#pragma mark - Focused

CDRExampleGroup * fdescribe(NSString *text, CDRSpecBlock block) {
    CDRExampleGroup *group = describe(text, block);
    group.focused = YES;
    return with_stack_address(group);
}

CDRExampleGroup * fcontext(NSString *text, CDRSpecBlock block) {
    CDRExampleGroup *group = context(text, block);
    group.focused = YES;
    return with_stack_address(group);
}

CDRExample * fit(NSString *text, CDRSpecBlock block) {
    CDRExample *example = it(text, block);
    example.focused = YES;
    return with_stack_address(example);
}

void fail(NSString *reason) {
    [[CDRSpecFailure specFailureWithReason:[NSString stringWithFormat:@"Failure: %@", reason]] raise];
}


/* Please be aware that CDRSpec+XCTestSupport does dynamic subclassing using this class as a mixin.
 * All ivars must be dynamically looked up. See that category for examples.
 *
 * DO NOT use synthesized properties - they will crash when running inside a test bundle.
 */
@implementation CDRSpec

@synthesize rootGroup = rootGroup_, currentGroup = currentGroup_, symbolicator = symbolicator_, fileName = fileName_;

#pragma mark Memory

- (void)dealloc {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    self.rootGroup = nil;
    self.currentGroup = nil;
    self.fileName = nil;
    self.symbolicator = nil;
#pragma clang diagnostic pop
    [super dealloc];
}

- (void)commonInit {
    NSString *text = self.class.description;
    self.rootGroup = [[[CDRExampleGroup alloc] initWithText:text
                                                     isRoot:YES] autorelease];
    self.rootGroup.parent = [CDRSpecHelper specHelper];
    self.currentGroup = self.rootGroup;
    self.symbolicator = [[[CDRSymbolicator alloc] init] autorelease];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)defineBehaviors {
    CDR_currentSpec = self;
    [self declareBehaviors];
    CDR_currentSpec = nil;
    [self markSpecClassForExampleBase:self.rootGroup];
}

- (void)markSpecClassForExampleBase:(CDRExampleBase *)example {
    example.spec = self;
    if (example.hasChildren) {
        for (CDRExampleBase *childExample in [(CDRExampleGroup *)example examples]) {
            [self markSpecClassForExampleBase:childExample];
        }
    }
}

- (void)markAsFocusedClosestToLineNumber:(NSUInteger)lineNumber {
    NSArray *children = self.allChildren;
    if (children.count == 0) return;

    NSMutableArray *addresses = [NSMutableArray array];
    for (CDRExampleBase *child in children) {
        [addresses addObject:[NSNumber numberWithUnsignedInteger:child.stackAddress]];
    }

    // Use symbolication to find out locations of examples.
    // We cannot turn describe/it/context into macros because:
    //  - making them non-function macros pollutes namespace
    //  - making them function macros causes xcode to highlight
    //    wrong lines of code if there are errors present in the code
    //  - also __LINE__ is unrolled from the outermost block
    //    which causes incorrect values
    NSError *error = nil;
    if ([self.symbolicator symbolicateAddresses:addresses error:&error]) {
        NSUInteger bestAddressIndex = [children indexOfObject:self.rootGroup];

        // Matches closest example/group located on or below specified line number
        // (only takes into account start of an example/group)
        for (NSInteger i = 0, shortestDistance = -1; i < addresses.count; i++) {
            NSInteger address = [[addresses objectAtIndex:i] integerValue];
            NSInteger distance = lineNumber - [self.symbolicator lineNumberForStackAddress:address];

            if (distance >= 0 && (distance < shortestDistance || shortestDistance == -1) ) {
                bestAddressIndex = i;
                shortestDistance = distance;
            }
        }
        [[children objectAtIndex:bestAddressIndex] setFocused:YES];
    } else if (error.domain == kCDRSymbolicatorErrorDomain) {
        if (error.code == kCDRSymbolicatorErrorNotAvailable) {
            printf("Spec location symbolication is not available.\n");
        } else if (error.code == kCDRSymbolicatorErrorNotSuccessful) {
            NSString *details = [error.userInfo objectForKey:kCDRSymbolicatorErrorMessageKey];
            printf("Spec location symbolication was not successful.\n"
                   "Details:\n%s\n", details.UTF8String);
        } else {
            printf("Spec location symbolication failed.\n");
        }
    }
}

- (NSArray *)allChildren {
    NSMutableArray *unseenChildren = [NSMutableArray arrayWithObject:self.rootGroup];
    NSMutableArray *seenChildren = [NSMutableArray array];

    while (unseenChildren.count > 0) {
        CDRExampleBase *child = [unseenChildren lastObject];
        [unseenChildren removeLastObject];

        if (child.hasChildren) {
            [unseenChildren addObjectsFromArray:[(CDRExampleGroup *)child examples]];
        }
        [seenChildren addObject:child];
    }
    return seenChildren;
}

@end
