#import "CDRSpec.h"
#import "CDRExample.h"
#import "CDRExampleGroup.h"
#import "CDRSpecFailure.h"
#import "CDRSpecHelper.h"
#import "CDRSymbolicator.h"

CDRSpec *CDR_currentSpec;

static void(^placeholderPendingTestBlock)() = ^{ it(@"is pending", PENDING); };

void beforeEach(CDRSpecBlock block) {
    [CDR_currentSpec.currentGroup addBefore:block];
}

void afterEach(CDRSpecBlock block) {
    [CDR_currentSpec.currentGroup addAfter:block];
}

#define with_stack_address(b) \
    ((b.stackAddress = CDRCallerStackAddress()), b)

CDRExampleGroup * describe(NSString *text, CDRSpecBlock block) {
    CDRExampleGroup *group = nil;
    if (block) {
        CDRExampleGroup *parentGroup = CDR_currentSpec.currentGroup;
        group = [CDRExampleGroup groupWithText:text];
        [parentGroup add:group];
        CDR_currentSpec.currentGroup = group;
        block();
        if ([group.examples count] == 0) {
            block = placeholderPendingTestBlock;
            block();
        }
        CDR_currentSpec.currentGroup = parentGroup;
    } else {
        group = describe(text, placeholderPendingTestBlock);
    }
    return with_stack_address(group);
}

CDRExampleGroup* (*context)(NSString *, CDRSpecBlock) = &describe;

void subjectAction(CDRSpecBlock block) {
    CDR_currentSpec.currentGroup.subjectActionBlock = block;
}

CDRExample * it(NSString *text, CDRSpecBlock block) {
    CDRExample *example = [CDRExample exampleWithText:text andBlock:block];
    [CDR_currentSpec.currentGroup add:example];
    return with_stack_address(example);
}

#pragma mark - Pending

CDRExampleGroup * xdescribe(NSString *text, CDRSpecBlock block) {
    CDRExampleGroup *group = describe(text, placeholderPendingTestBlock);
    return with_stack_address(group);
}

CDRExampleGroup* (*xcontext)(NSString *, CDRSpecBlock) = &xdescribe;

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

CDRExampleGroup* (*fcontext)(NSString *, CDRSpecBlock) = &fdescribe;

CDRExample * fit(NSString *text, CDRSpecBlock block) {
    CDRExample *example = it(text, block);
    example.focused = YES;
    return with_stack_address(example);
}

void fail(NSString *reason) {
    [[CDRSpecFailure specFailureWithReason:[NSString stringWithFormat:@"Failure: %@", reason]] raise];
}

@implementation CDRSpec

@synthesize
    currentGroup = currentGroup_,
    rootGroup = rootGroup_,
    fileName = fileName_,
    symbolicator = symbolicator_;

#pragma mark Memory

- (id)init {
    if (self = [super init]) {
        self.rootGroup = [[[CDRExampleGroup alloc] initWithText:[[self class] description] isRoot:YES] autorelease];
        self.rootGroup.parent = [CDRSpecHelper specHelper];
        self.currentGroup = self.rootGroup;
        self.symbolicator = [[[CDRSymbolicator alloc] init] autorelease];
    }
    return self;
}

- (void)dealloc {
    self.rootGroup = nil;
    self.currentGroup = nil;
    self.fileName = nil;
    self.symbolicator = nil;
    [super dealloc];
}

- (void)defineBehaviors {
    CDR_currentSpec = self;
    [self declareBehaviors];
    CDR_currentSpec = nil;
    [self markSpecClassForExampleBase:self.rootGroup];
}

- (void)failWithException:(NSException *)exception {
    [[CDRSpecFailure specFailureWithReason:exception.reason] raise];
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
