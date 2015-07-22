#import "CDRXCTestObserver.h"
#import "CDRFunctions.h"
#import "CDRPrivateFunctions.h"
#import "CDRReportDispatcher.h"
#import "CDRSpec.h"
#import <objc/runtime.h>

#pragma mark - Running Test Bundles
#import "CDRXTestSuite.h"
#import "CDRRuntimeUtilities.h"

void CDRAddCedarSpecsToXCTestSuite(XCTestSuite *testSuite);

@interface CDRXCTestObserver ()

@property (assign) BOOL observedTestSuiteStart;

@end

@interface CDRXCTestSupport : NSObject
- (id)testSuiteWithName:(NSString *)name;
- (id)defaultTestSuite;
- (id)testSuiteForBundlePath:(NSString *)bundlePath;
- (id)initWithName:(NSString *)aName;

- (id)CDR_original_defaultTestSuite;

- (void)addTest:(id)test;
@end

@implementation CDRXCTestObserver

- (void)testSuiteWillStart:(XCTestSuite *)testSuite {
    if (self.observedTestSuiteStart) {
        return;
    }

    CDRAddCedarSpecsToXCTestSuite(testSuite);

    self.observedTestSuiteStart = YES;
}

@end

static id CDRCreateXCTestSuite() {
    Class testSuiteClass = NSClassFromString(@"XCTestSuite") ?: NSClassFromString(@"SenTestSuite");
    Class testSuiteSubclass = NSClassFromString(@"_CDRXTestSuite");

    if (testSuiteSubclass == nil) {
        size_t size = class_getInstanceSize([CDRXTestSuite class]) - class_getInstanceSize([NSObject class]);
        testSuiteSubclass = objc_allocateClassPair(testSuiteClass, "_CDRXTestSuite", size);
        CDRCopyClassInternalsFromClass([CDRXTestSuite class], testSuiteSubclass);
        objc_registerClassPair(testSuiteSubclass);
    }

    id testSuite = [[[(id)testSuiteSubclass alloc] initWithName:@"Cedar"] autorelease];

    CDRAddCedarSpecsToXCTestSuite(testSuite);

    return testSuite;
}

void CDRInjectIntoXCTestRunner() {
    // if possible, use the new XCTestObservation protocol available in Xcode 7
    Class observationCenterClass = NSClassFromString(@"XCTestObservationCenter");
    if (observationCenterClass && [observationCenterClass respondsToSelector:@selector(sharedTestObservationCenter)]) {
        id observationCenter = [observationCenterClass sharedTestObservationCenter];
        static CDRXCTestObserver *xcTestObserver;
        xcTestObserver = [[CDRXCTestObserver alloc] init];
        [observationCenter addTestObserver:xcTestObserver];

        return;
    }

    Class testSuiteClass = NSClassFromString(@"XCTestSuite") ?: NSClassFromString(@"SenTestSuite");
    if (!testSuiteClass) {
        [[NSException exceptionWithName:@"CedarNoTestFrameworkAvailable" reason:@"You must link against either the XCTest or SenTestingKit frameworks." userInfo:nil] raise];
    }

    Class testSuiteMetaClass = object_getClass(testSuiteClass);
    Method m = class_getClassMethod(testSuiteClass, @selector(defaultTestSuite));

    class_addMethod(testSuiteMetaClass, @selector(CDR_original_defaultTestSuite), method_getImplementation(m), method_getTypeEncoding(m));
    IMP newImp = imp_implementationWithBlock(^id(id self){
        id defaultSuite = [self CDR_original_defaultTestSuite];
        [defaultSuite addTest:CDRCreateXCTestSuite()];
        return defaultSuite;
    });
    class_replaceMethod(testSuiteMetaClass, @selector(defaultTestSuite), newImp, method_getTypeEncoding(m));
}

void CDRAddCedarSpecsToXCTestSuite(XCTestSuite *testSuite) {
    unsigned int seed = CDRGetRandomSeed();

    CDRDefineSharedExampleGroups();
    CDRDefineGlobalBeforeAndAfterEachBlocks();

    NSArray *specClasses = CDRSpecClassesToRun();
    NSArray *permutedSpecClasses = CDRPermuteSpecClassesWithSeed(specClasses, seed);
    NSArray *specs = CDRSpecsFromSpecClasses(permutedSpecClasses);

    CDRMarkFocusedExamplesInSpecs(specs);
    CDRMarkXcodeFocusedExamplesInSpecs(specs, [[NSProcessInfo processInfo] arguments]);

    CDRReportDispatcher *dispatcher = [[[CDRReportDispatcher alloc] initWithReporters:CDRReportersToRun()] autorelease];

    NSArray *groups = CDRRootGroupsFromSpecs(specs);
    [dispatcher runWillStartWithGroups:groups andRandomSeed:seed];

    for (CDRSpec *spec in specs) {
        [testSuite addTest:[spec testSuiteWithRandomSeed:seed dispatcher:dispatcher]];
    }
}
