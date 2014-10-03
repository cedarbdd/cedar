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
#import "NSInvocation+CDRXExample.h"


const char *CDRXSpecKey;

#pragma mark - XCTest forward declarations
@interface CDR_XCTestSuite : NSObject
- (id)testSuiteWithName:(NSString *)name;
- (id)defaultTestSuite;
- (void)addTest:(id)test;
@end

#pragma mark - SenTestingKit forward declarations
@interface CDR_SenTestSuite : NSObject
- (void)failWithException:(NSException *)anException;
@end

@interface NSException (SenTestFailure)
+ (NSException *) failureInFile:(NSString *) filename atLine:(int) lineNumber withDescription:(NSString *) formatString, ...;
@end


#pragma mark - CDRSpec XCTest support
@implementation CDRSpec (XCTestSupport)

#pragma mark - Public

- (id)testSuiteWithRandomSeed:(unsigned int)seed dispatcher:(CDRReportDispatcher *)dispatcher {
    NSString *className = NSStringFromClass([self class]);
    Class testSuiteClass = NSClassFromString(@"XCTestSuite") ?: NSClassFromString(@"SenTestSuite");
    id testSuite = [(id)testSuiteClass testSuiteWithName:className];
    Class newXCTestSubclass = [self createTestCaseSubclass];

    CDROTestNamer *namer = [[[CDROTestNamer alloc] init] autorelease];
    NSArray *examples = [self allExamplesToRun];

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
            invocation.dispatcher = dispatcher;
            invocation.example = example;
            invocation.specClassName = className;
            [testInvocations addObject:invocation];
        }
    }

    // save the spec to prevent premature deallocation
    objc_setAssociatedObject(testSuite, &CDRXSpecKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [(id)newXCTestSubclass setTestInvocations:CDRShuffleItemsInArrayWithSeed(testInvocations, seed)];

    id defaultTestSuite = [(id)newXCTestSubclass defaultTestSuite];
    for (id test in [defaultTestSuite valueForKey:@"tests"]) {
        [testSuite addTest:test];
    }

    return testSuite;
}

#pragma mark - Private

- (Class)createTestCaseSubclass {
    NSString *className = NSStringFromClass([self class]);
    Class testCaseClass = NSClassFromString(@"XCTestCase") ?: NSClassFromString(@"SenTestCase");
    NSString *newClassName = [NSString stringWithFormat:@"_%@", className];
    Class newXCTestSubclass = NSClassFromString(newClassName);
    if (!newXCTestSubclass) {
        newXCTestSubclass = [self createMixinSubclassOf:testCaseClass
                                           newClassName:newClassName
                                          templateClass:[CDRXCTestCase class]];
    }

    return newXCTestSubclass;
}

- (NSArray *)allExamplesToRun {
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
    objc_registerClassPair(newSubclass);

    return newSubclass;
}

- (void)createTestMethodForSelector:(SEL)selector onClass:(Class)aClass {
    IMP imp = imp_implementationWithBlock(^(id instance){
        CDRExample *example = [[instance invocation] example];
        CDRExampleGroup *parentGroup = (CDRExampleGroup *)example.parent;
        CDRReportDispatcher *theDispatcher = [[instance invocation] dispatcher];
        while (![parentGroup isEqual:example.spec.rootGroup]) {
            [theDispatcher runWillStartExampleGroup:parentGroup];
            parentGroup = (CDRExampleGroup *)[parentGroup parent];
        }

        [example runWithDispatcher:theDispatcher];
        if (example.failure) {
            if ([instance respondsToSelector:@selector(recordFailureWithDescription:inFile:atLine:expected:)]) {
                [instance recordFailureWithDescription:example.failure.reason
                                                inFile:example.failure.fileName
                                                atLine:example.failure.lineNumber
                                              expected:YES];
            } else {
                [instance failWithException:[NSException failureInFile:example.failure.fileName atLine:example.failure.lineNumber withDescription:example.failure.description]];
            }
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
