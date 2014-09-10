#import <objc/runtime.h>

#import "CDRReportDispatcher.h"
#import "CDRSpec.h"
#import "CDRExampleGroup.h"
#import "CDRExample.h"
#import "CDROTestNamer.h"
#import "CDRRuntimeUtilities.h"
#import "CDRSpecFailure.h"

@interface CDR_XCTest : NSObject
- (id)run;
- (void)setUp;
- (void)tearDown;
- (void)performTest:(id)run;
@end

@interface CDR_XCTestSuite : NSObject
- (id)testSuiteWithName:(NSString *)name;
- (id)defaultTestSuite;

- (void)addTest:(id)test;
- (NSArray *)tests;
- (NSArray *)allTests; // SenTestingKit
@end

@interface CDR_XCTestCase : NSObject
+ (id)testRunWithTest:(id)test;
+ (id)testCaseWithInvocation:(NSInvocation *)invocation;
- (id)initWithInvocation:(NSInvocation *)invocation;

@end

@interface CDR_XCTestRunner : NSObject
- (void)start;
- (void)stop;
@end

@interface CDRSpec ()
@property (strong) NSInvocation *invocation; // defined by XCTestCase

- (void)commonInit;
@end

@interface CDRSpec (XCTestCaseMethods)
- (void)recordFailureWithDescription:(NSString *)description inFile:(NSString *)filename atLine:(NSUInteger)lineNumber expected:(BOOL)expected;
@end

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
    [self defineBehaviors];

    NSInvocation *invocation = [self invocation];
    invocation.target = self;
    [invocation invoke];
}

+ (NSArray *)testInvocations {
    NSMutableArray *invocations = [NSMutableArray array];
    CDRSpec *spec = [[[self alloc] init] autorelease];
    [spec defineBehaviors];

    CDROTestNamer *namer = [[[CDROTestNamer alloc] init] autorelease];
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

    CDROTestNamer *namer = [[[CDROTestNamer alloc] init] autorelease];
    Method m = class_getInstanceMethod([self class], @selector(defineBehaviors));
    NSArray *examples = [spec allExamples];
    NSUInteger i = 0;
    for (CDRExample *example in examples) {
        IMP imp = imp_implementationWithBlock(^(id instance){
            CDRExample *theExample = [instance allExamples][i];
            [theExample runWithDispatcher:nil];
            if (theExample.failure) {
                [instance recordFailureWithDescription:theExample.failure.reason inFile:theExample.failure.fileName atLine:theExample.failure.lineNumber expected:YES];
            }
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
