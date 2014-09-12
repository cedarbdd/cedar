#import <objc/runtime.h>

#import "CDRReportDispatcher.h"
#import "CDRSpec.h"
#import "CDRExampleGroup.h"
#import "CDRExample.h"
#import "CDROTestNamer.h"
#import "CDRRuntimeUtilities.h"
#import "CDRFunctions.h"
#import "CDRSymbolicator.h"
#import "CDRXCTestCase.h"


@interface CDR_XCTestSuite : NSObject
- (id)testSuiteWithName:(NSString *)name;
- (id)defaultTestSuite;
- (void)addTest:(id)test;
@end


@implementation CDRSpec (XCTestSupport)

#pragma mark - Public

- (id)testSuiteWithRandomSeed:(unsigned int)seed dispatcher:(CDRReportDispatcher *)dispatcher {
    NSString *className = NSStringFromClass([self class]);
    Class testSuiteClass = NSClassFromString(@"XCTestSuite") ?: NSClassFromString(@"SenTestSuite");
    Class testCaseClass = NSClassFromString(@"XCTestCase") ?: NSClassFromString(@"SenTestCase");
    id testSuite = [(id)testSuiteClass testSuiteWithName:className];

    NSString *newClassName = [NSString stringWithFormat:@"_%@", className];
    Class newXCTestSubclass = NSClassFromString(newClassName);
    BOOL isCreatingSubclass = !newXCTestSubclass;
    if (isCreatingSubclass) {
        newXCTestSubclass = [self createMixinSubclassOf:testCaseClass
                                           newClassName:newClassName
                                          templateClass:[CDRXCTestCase class]];
    }

    CDROTestNamer *namer = [[[CDROTestNamer alloc] init] autorelease];
    NSArray *examples = [self allExamples];

    NSMutableArray *testInvocations = [NSMutableArray array];
    for (CDRExample *example in examples) {
        if (!example.isPending) {
            NSString *methodName = [namer methodNameForExample:example withClassName:NSStringFromClass([self class])];
            SEL selector = NSSelectorFromString(methodName);
            NSMethodSignature *methodSignature = [newXCTestSubclass instanceMethodSignatureForSelector:selector];

            if (!methodSignature) {
                [self createTestMethodForSelector:selector onClass:newXCTestSubclass];
                methodSignature = [newXCTestSubclass instanceMethodSignatureForSelector:selector];
            }

            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            invocation.selector = selector;
            [testInvocations addObject:invocation];

            objc_setAssociatedObject(invocation, &CDRXDispatcherKey, dispatcher, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(invocation, &CDRXExampleKey, example, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(invocation, &CDRXSpecClassNameKey, className, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }

    // save the spec to prevent premature deallocation
    objc_setAssociatedObject(testSuite, &CDRXSpecKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    // save for +[testInvocations]
    objc_setAssociatedObject(newXCTestSubclass, &CDRXTestInvocationsKey, CDRShuffleItemsInArrayWithSeed(testInvocations, seed), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    id defaultTestSuite = [(id)newXCTestSubclass defaultTestSuite];
    for (id test in [defaultTestSuite valueForKey:@"tests"]) {
        [testSuite addTest:test];
    }

    return testSuite;
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

- (Class)createMixinSubclassOf:(Class)parentClass newClassName:(NSString *)newClassName templateClass:(Class)templateClass {
    size_t size = class_getInstanceSize(templateClass) - class_getInstanceSize([NSObject class]);
    Class newSubclass = objc_allocateClassPair(parentClass, [newClassName UTF8String], size);

    CDRCopyClassInternalsFromClass(templateClass, newSubclass);
    CDRCopyClassMethodsFromClass(templateClass, newSubclass);
    objc_registerClassPair(newSubclass);

    return newSubclass;
}

- (void)createTestMethodForSelector:(SEL)selector onClass:(Class)aClass {
    IMP imp = imp_implementationWithBlock(^(id instance){
        CDRExample *example = objc_getAssociatedObject([instance invocation], &CDRXExampleKey);
        CDRExampleGroup *parentGroup = (CDRExampleGroup *)example.parent;
        CDRReportDispatcher *theDispatcher = objc_getAssociatedObject([instance invocation], &CDRXDispatcherKey);
        while (![parentGroup isEqual:example.spec.rootGroup]) {
            [theDispatcher runWillStartExampleGroup:parentGroup];
            parentGroup = (CDRExampleGroup *)[parentGroup parent];
        }

        [example runWithDispatcher:theDispatcher];
        if (example.failure) {
            [instance recordFailureWithDescription:example.failure.reason
                                            inFile:example.failure.fileName
                                            atLine:example.failure.lineNumber
                                          expected:YES];
        }

        parentGroup = (CDRExampleGroup *)example.parent;
        while (![parentGroup isEqual:example.spec.rootGroup]) {
            [theDispatcher runDidFinishExampleGroup:parentGroup];
            parentGroup = (CDRExampleGroup *)[parentGroup parent];
        }
    });
    Method m = class_getInstanceMethod([self class], @selector(defineBehaviors));

    const char *encoding = method_getTypeEncoding(m);
    class_addMethod(aClass, selector, imp, encoding);
}

@end
