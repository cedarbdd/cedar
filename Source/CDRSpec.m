#import "CDRSpec.h"
#import "CDRExample.h"
#import "CDRExampleGroup.h"
#import "CDRSpecFailure.h"
#import "CDRSpecHelper.h"
#import "CDRSymbolicator.h"
#import <objc/runtime.h>

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


#pragma mark - Experimental XCTest Support

@interface CDRXCTestSupport : NSObject
- (id)testSuiteWithName:(NSString *)name;
- (id)defaultTestSuite;
- (id)testSuiteForBundlePath:(NSString *)bundlePath;
- (id)testSuiteForTestCaseWithName:(NSString *)name;
- (id)testSuiteForTestCaseClass:(Class)testCaseClass;

- (void)addTest:(id)test;
- (NSArray *)tests;
- (NSArray *)allTests; // SenTestingKit

+ (id)testCaseWithInvocation:(NSInvocation *)invocation;
- (id)initWithInvocation:(NSInvocation *)invocation;


+ (id)testRunWithTest:(id)test;


@property (readonly) NSUInteger testCaseCount;
@property (readonly, copy) NSString *name;
@property (readonly) Class testRunClass;
- (void)performTest:(id)run;
- (id)run;
- (void)setUp;
- (void)tearDown;


- (void)start;
- (void)stop;
@end

#import "CDRReportDispatcher.h"
#import "CDRSpec.h"
#import "CDRExampleGroup.h"
#import "CDROTestNamer.h"
#import "CDRRuntimeUtilities.h"

@interface CDRSpec ()
@property (strong) NSInvocation *invocation; // defined by XCTestCase
@end

@implementation CDRSpec

- (CDRExampleGroup *)currentGroup {
    Ivar ivar = object_getInstanceVariable(self, "currentGroup_", NULL);
    return object_getIvar(self, ivar);
}

- (void)setCurrentGroup:(CDRExampleGroup *)currentGroup {
    CDRExampleGroup *oldGroup = [self currentGroup];
    Ivar ivar = object_getInstanceVariable(self, "currentGroup_", NULL);
    object_setIvar(self, ivar, [currentGroup retain]);
    [oldGroup release];
}

- (CDRExampleGroup *)rootGroup {
    Ivar ivar = object_getInstanceVariable(self, "rootGroup_", NULL);
    return object_getIvar(self, ivar);
}

- (void)setRootGroup:(CDRExampleGroup *)rootGroup {
    CDRExampleGroup *oldGroup = [self rootGroup];
    Ivar ivar = object_getInstanceVariable(self, "rootGroup_", NULL);
    object_setIvar(self, ivar, [rootGroup retain]);
    [oldGroup release];
}

- (NSString *)fileName {
    Ivar ivar = object_getInstanceVariable(self, "fileName_", NULL);
    return object_getIvar(self, ivar);
}

- (void)setFileName:(NSString *)fileName {
    NSString *oldFileName = [self fileName];
    object_setInstanceVariable(self, "fileName_", [fileName retain]);
    [oldFileName release];
}

- (CDRSymbolicator *)symbolicator {
    Ivar ivar = object_getInstanceVariable(self, "symbolicator_", NULL);
    return object_getIvar(self, ivar);
}

- (void)setSymbolicator:(CDRSymbolicator *)symbolicator {
    CDRSymbolicator *oldSymbolicator = [self symbolicator];
    object_setInstanceVariable(self, "symbolicator_", [symbolicator retain]);
    [oldSymbolicator release];
}

#pragma mark Memory

- (void)dealloc {
    self.rootGroup = nil;
    self.currentGroup = nil;
    self.fileName = nil;
    self.symbolicator = nil;
    [super dealloc];
}

- (void)commonInit {
    self.rootGroup = [[[CDRExampleGroup alloc] initWithText:[[self class] description] isRoot:YES] autorelease];
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

- (NSArray *)allExamples {
    NSMutableArray *examples = [NSMutableArray array];
    NSMutableArray *groupsQueue = [NSMutableArray arrayWithArray:self.rootGroup.examples];
    while (groupsQueue.count) {
        CDRExampleBase *exampleBase = [groupsQueue objectAtIndex:0];
        if (exampleBase.hasChildren) {
            [groupsQueue addObjectsFromArray:[(CDRExampleGroup *)exampleBase examples]];
        } else {
            [examples addObject:exampleBase];
        }
        [groupsQueue removeObjectAtIndex:0];
    }
    return examples;
}

@end

@implementation CDRSpec (XCTestSupport)

- (instancetype)initWithInvocation:(NSInvocation *)invocation {
    Class parentClass = class_getSuperclass([self class]);
    IMP constructor = class_getMethodImplementation(parentClass, @selector(initWithInvocation:));
    self = ((id (*)(id instance, SEL cmd, NSInvocation *))constructor)(self, _cmd, invocation);
    if (self) {
        [self commonInit];
    }
    return self;
}

- (NSString *)name {
    return [NSString stringWithFormat:@"-[%@ %@]",
            [self testClassName],
            [self testMethodName]];
}

- (NSString *)testClassName {
    return [NSStringFromClass([self class]) substringFromIndex:1];
}

- (NSString *)testMethodName {
    return NSStringFromSelector([[self invocation] selector]);
}

- (void)invokeTest {
     [self defineBehaviors];

    NSInvocation *invocation = [self invocation];
    invocation.target = self;
    [invocation invoke];
}

+ (NSArray *)testInvocations {
    NSMutableArray *invocations = [NSMutableArray array];
    CDRSpec *spec = [[self new] autorelease];
    [spec defineBehaviors];

    CDROTestNamer *namer = [[CDROTestNamer new] autorelease];
    for (CDRExample *example in [spec allExamples]) {
        SEL selector = NSSelectorFromString([namer methodNameForExample:example withClassName:[NSStringFromClass([self class]) substringFromIndex:1]]);
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self instanceMethodSignatureForSelector:selector]];
        invocation.selector = selector;
        [invocations addObject:invocation];
    };

    return invocations;
}

- (id)testSuite {
    NSString *className = NSStringFromClass([self class]);
    Class testSuiteClass = NSClassFromString(@"XCTestSuite") ?: NSClassFromString(@"SenTestSuite");
    id testSuite = [(id)testSuiteClass testSuiteWithName:className];

    NSString *newClassName = [NSString stringWithFormat:@"_%@", className];
    size_t size = class_getInstanceSize([self class]) - class_getInstanceSize([NSObject class]);
    Class testCaseClass = NSClassFromString(@"XCTestCase") ?: NSClassFromString(@"SenTestCase");
    Class newXCTestSubclass = objc_allocateClassPair(testCaseClass, [newClassName UTF8String], size);

    NSSet *excludes = [NSSet setWithObject:@"testSuite"];
    CDRCopyClassInternalsFromClass([self superclass], newXCTestSubclass, excludes);
    CDRCopyClassInternalsFromClass([self class], newXCTestSubclass, excludes);
    CDRCopyClassInternalsFromClass(object_getClass([self superclass]), object_getClass(newXCTestSubclass), excludes);
    objc_registerClassPair(newXCTestSubclass);

    CDRSpec *spec = [[[newXCTestSubclass alloc] init] autorelease];

    [spec defineBehaviors];

    CDROTestNamer *namer = [[CDROTestNamer new] autorelease];
    Method m = class_getInstanceMethod([self class], @selector(defineBehaviors));
    NSArray *examples = [spec allExamples];
    NSUInteger i = 0;
    for (CDRExample *example in examples) {
        IMP imp = imp_implementationWithBlock(^(id instance){
            [instance defineBehaviors];
            CDRExample *theExample = [instance allExamples][i];
            [theExample runWithDispatcher:nil];
        });
        class_addMethod([spec class],
                        NSSelectorFromString([namer methodNameForExample:example withClassName:NSStringFromClass([self class])]),
                        imp,
                        method_getTypeEncoding(m));
        i++;
    }

    id defaultTestSuite = [(id)[spec class] defaultTestSuite];
    for (id test in [defaultTestSuite valueForKey:@"tests"]) {
        [testSuite addTest:test];
    }

    return testSuite;
}

@end
