#import <objc/runtime.h>

#import "CDRReportDispatcher.h"
#import "CDRSpec.h"
#import "CDRExampleGroup.h"
#import "CDRExample.h"
#import "CDROTestNamer.h"
#import "CDRRuntimeUtilities.h"
#import "CDRSpecFailure.h"
#import "CDRFunctions.h"
#import "CDRSymbolicator.h"

@interface CDR_XCTest : NSObject
- (id)run;
@end

@interface CDR_XCTestSuite : NSObject
- (id)testSuiteWithName:(NSString *)name;
- (id)defaultTestSuite;

- (void)addTest:(id)test;
@end

@interface CDR_XCTestCase : NSObject
- (id)initWithInvocation:(NSInvocation *)invocation;

@end

@interface CDRSpec ()
@property (strong) NSInvocation *invocation; // defined by XCTestCase

- (void)commonInit;
@end

@interface CDRSpec (XCTestCaseMethods)
- (void)recordFailureWithDescription:(NSString *)description inFile:(NSString *)filename atLine:(NSUInteger)lineNumber expected:(BOOL)expected;
@end

const char *CDRXSeedKey;
const char *CDRXRootGroupKey;
const char *CDRXFullExampleNamesKey;

/*! Under iOS XCTest, CDRSpec's ivars, properties, and methods get transferred
 *  over to a dynamically generated subclass of XCTestCase. This allows us to control
 *  the behavior of the tests running, while allowing for XCTest case to communicate
 *  to Xcode and related processes (e.g.: testmanagerd) normally.
 *
 *  These accessors are explicitly written out because the synthesized ivar methods
 *  would reference static ivar offsets that are incorrect for this dynamically generated class.
 */
@implementation CDRSpec (XCTestSupport)

#pragma mark - Property Overrides

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

#pragma mark - Memory

- (instancetype)initWithInvocation:(NSInvocation *)invocation {
    Class parentClass = class_getSuperclass([self class]);
    IMP constructor = class_getMethodImplementation(parentClass, @selector(initWithInvocation:));
    self = ((id (*)(id instance, SEL cmd, NSInvocation *))constructor)(self, _cmd, invocation);
    if (self) {
        [self commonInit];
    }
    return self;
}

#pragma mark - Private

- (NSArray *)allExamples {
    NSMutableArray *examples = [NSMutableArray array];
    NSMutableArray *groupsQueue = [NSMutableArray arrayWithArray:self.rootGroup.examples];
    while (groupsQueue.count) {
        CDRExampleBase *exampleBase = [groupsQueue objectAtIndex:0];
        [groupsQueue removeObjectAtIndex:0];
        if (exampleBase.hasChildren) {
            [groupsQueue addObjectsFromArray:[(CDRExampleGroup *)exampleBase examples]];
        } else if ([exampleBase shouldRun]) {
            [examples addObject:exampleBase];
        }
    }
    return examples;
}

- (Class)createMixinSubclassOf:(Class)parentClass excluding:(NSSet *)excludedMethods {
    NSString *className = NSStringFromClass([self class]);
    NSString *newClassName = [NSString stringWithFormat:@"_%@", className];
    size_t size = class_getInstanceSize([self class]) - class_getInstanceSize([NSObject class]);
    Class newSubclass = objc_allocateClassPair(parentClass, [newClassName UTF8String], size);

    CDRCopyClassInternalsFromClass([self superclass], newSubclass, excludedMethods);
    CDRCopyClassInternalsFromClass([self class], newSubclass, excludedMethods);
    CDRCopyClassInternalsFromClass(object_getClass([self superclass]), object_getClass(newSubclass), excludedMethods);
    objc_registerClassPair(newSubclass);

    return newSubclass;
}

#pragma mark - XCTestCase Overrides

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
    self.rootGroup = objc_getAssociatedObject([self class], &CDRXRootGroupKey);
    NSInvocation *invocation = [self invocation];
    invocation.target = self;
    [invocation invoke];
}

+ (NSArray *)testInvocations {
    NSMutableArray *invocations = [NSMutableArray array];
    NSArray *methodNames = objc_getAssociatedObject(self, &CDRXFullExampleNamesKey);

    NSNumber *seed = objc_getAssociatedObject(self, &CDRXSeedKey);
    NSArray *shuffledMethodNames = CDRShuffleItemsInArrayWithSeed(methodNames, [seed unsignedIntValue]);
    for (NSString *methodName in shuffledMethodNames) {
        SEL selector = NSSelectorFromString(methodName);
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self instanceMethodSignatureForSelector:selector]];
        invocation.selector = selector;
        [invocations addObject:invocation];
    };

    return invocations;
}

#pragma mark - Public

- (id)testSuiteWithRandomSeed:(unsigned int)seed dispatcher:(CDRReportDispatcher *)dispatcher {
    NSString *className = NSStringFromClass([self class]);
    Class testSuiteClass = NSClassFromString(@"XCTestSuite") ?: NSClassFromString(@"SenTestSuite");
    Class testCaseClass = NSClassFromString(@"XCTestCase") ?: NSClassFromString(@"SenTestCase");
    id testSuite = [(id)testSuiteClass testSuiteWithName:className];

    NSSet *excludes = [NSSet setWithObject:@"testSuiteWithRandomSeed:dispatcher:"];
    Class newXCTestSubclass = [self createMixinSubclassOf:testCaseClass excluding:excludes];

    CDRSpec *spec = [[[newXCTestSubclass alloc] init] autorelease];
    objc_setAssociatedObject([spec class], &CDRXSeedKey, [NSNumber numberWithUnsignedInt:seed], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    /*
     *  XCTest copies our spec instances (by calling the constructor again), so we can't use properties or ivars
     *  We're effectively stashing information about the spec instance on the class.
     *  But since each spec instance is a separate class, this should be fine.
     */
    [spec defineBehaviors];
    objc_setAssociatedObject([spec class], &CDRXRootGroupKey, spec.rootGroup, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    CDROTestNamer *namer = [[[CDROTestNamer alloc] init] autorelease];
    Method m = class_getInstanceMethod([self class], @selector(defineBehaviors));
    NSArray *examples = [spec allExamples];

    NSMutableArray *fullExampleNames = [NSMutableArray array];
    for (CDRExample *example in examples) {
        if (!example.isPending) {
            IMP imp = imp_implementationWithBlock(^(id instance){
                CDRExampleGroup *parentGroup = (CDRExampleGroup *)example.parent;
                [dispatcher runWillStartExampleGroup:parentGroup];

                [example runWithDispatcher:dispatcher];
                if (example.failure) {
                    [instance recordFailureWithDescription:example.failure.reason
                                                    inFile:example.failure.fileName
                                                    atLine:example.failure.lineNumber
                                                  expected:YES];
                }

                [dispatcher runDidFinishExampleGroup:parentGroup];
            });
            NSString *methodName = [namer methodNameForExample:example withClassName:NSStringFromClass([self class])];
            BOOL succeeded = class_addMethod([spec class], NSSelectorFromString(methodName), imp, method_getTypeEncoding(m));
            [fullExampleNames addObject:methodName];
            NSAssert(succeeded, @"Example name already exists: '%@' as method '%@'", [example fullText], methodName);
        }
    }
    objc_setAssociatedObject([spec class], &CDRXFullExampleNamesKey, fullExampleNames, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    id defaultTestSuite = [(id)[spec class] defaultTestSuite];
    for (id test in [defaultTestSuite valueForKey:@"tests"]) {
        [testSuite addTest:test];
    }

    return testSuite;
}

@end
