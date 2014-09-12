#import <UIKit/UIKit.h>
#import "CDROTestIPhoneRunner.h"
#import "CDROTestHelper.h"
#import "CedarApplicationDelegate.h"
#import "HeadlessSimulatorWorkaround.h"
#import "CDRFunctions.h"
#import "CDRExample.h"
#import <objc/runtime.h>
#import "CDRRuntimeUtilities.h"
#import "CDRXTestSuite.h"

@interface CDRXCTestSupport : NSObject
- (id)testSuiteWithName:(NSString *)name;
- (id)defaultTestSuite;
- (id)testSuiteForBundlePath:(NSString *)bundlePath;
- (id)testSuiteForTestCaseWithName:(NSString *)name;
- (id)testSuiteForTestCaseClass:(Class)testCaseClass;
- (id)initWithName:(NSString *)aName;

- (id)CDR_original_defaultTestSuite;

- (void)addTest:(id)test;

- (id)initWithInvocation:(NSInvocation *)invocation;
@end

#import "CDRReportDispatcher.h"
#import "CDRSpec.h"
extern void CDRDefineSharedExampleGroups();
extern void CDRDefineGlobalBeforeAndAfterEachBlocks();
extern NSArray *CDRReportersFromEnv(const char *defaultReporterClassName);
extern unsigned int CDRGetRandomSeed();
extern NSArray *CDRSpecClassesToRun();
extern NSArray *CDRPermuteSpecClassesWithSeed(NSArray *unsortedSpecClasses, unsigned int seed);
extern NSArray *CDRSpecsFromSpecClasses(NSArray *specClasses);
extern void CDRMarkFocusedExamplesInSpecs(NSArray *specs);
extern void CDRMarkXcodeFocusedExamplesInSpecs(NSArray *specs, NSArray *arguments);
extern NSArray *CDRRootGroupsFromSpecs(NSArray *specs);

static id CDRCreateXCTestSuite() {
    Class testSuiteClass = NSClassFromString(@"XCTestSuite") ?: NSClassFromString(@"SenTestSuite");
    Class testSuiteSubclass = NSClassFromString(@"_CDRXTestSuite");

    if (testSuiteSubclass == nil) {
        size_t size = class_getInstanceSize([CDRXTestSuite class]) - class_getInstanceSize([NSObject class]);
        testSuiteSubclass = objc_allocateClassPair(testSuiteClass, "_CDRXTestSuite", size);
        CDRCopyClassInternalsFromClass([CDRXTestSuite class], testSuiteSubclass);
        objc_registerClassPair(testSuiteClass);
    }

    id testSuite = [[(id)testSuiteSubclass alloc] initWithName:@"Cedar"];
    CDRDefineSharedExampleGroups();
    CDRDefineGlobalBeforeAndAfterEachBlocks();

    unsigned int seed = CDRGetRandomSeed();

    NSArray *specClasses = CDRSpecClassesToRun();
    NSArray *permutedSpecClasses = CDRPermuteSpecClassesWithSeed(specClasses, seed);
    NSArray *specs = CDRSpecsFromSpecClasses(permutedSpecClasses);
    CDRMarkFocusedExamplesInSpecs(specs);
    CDRMarkXcodeFocusedExamplesInSpecs(specs, [[NSProcessInfo processInfo] arguments]);

    CDRReportDispatcher *dispatcher = [[[CDRReportDispatcher alloc] initWithReporters:CDRReportersToRun()] autorelease];

    [CDRXTestSuite setDispatcher:dispatcher];

    NSArray *groups = CDRRootGroupsFromSpecs(specs);
    [dispatcher runWillStartWithGroups:groups andRandomSeed:seed];

    for (CDRSpec *spec in specs) {
        [testSuite addTest:[spec testSuiteWithRandomSeed:seed dispatcher:dispatcher]];
    }
    return testSuite;
}

static void CDRInjectIntoXCTestRunner() {
    Class testSuiteClass = NSClassFromString(@"XCTestSuite") ?: NSClassFromString(@"SenTestSuite");
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




@interface UIApplication (PrivateAppleMethods)
- (void)_terminateWithStatus:(int)status;
@end

@implementation NSBundle (MainBundleHijack)
static NSBundle *mainBundle__ = nil;

NSBundle *CDRMainBundle(id self, SEL _cmd) {
    return mainBundle__;
}

+ (void)load {
    suppressStandardPipesWhileLoadingClasses();

    NSString *extension = nil;;

    if (CDRIsXCTest()) {
        extension = @".xctest";
    } else if (CDRIsOCTest()) {
        extension = @".octest";
    }

    if (!extension)
        return;

    BOOL mainBundleIsApp = [[[NSBundle mainBundle] bundlePath] hasSuffix:@".app"];
    BOOL mainBundleIsTestBundle = [[[NSBundle mainBundle] bundlePath] hasSuffix:extension];

    if (!mainBundleIsApp && !mainBundleIsTestBundle) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        for (NSBundle *bundle in [NSBundle allBundles]) {
            if ([[bundle bundlePath] hasSuffix:extension]) {
                mainBundle__ = [bundle retain];
                Class nsBundleMetaClass = objc_getMetaClass("NSBundle");
                class_replaceMethod(nsBundleMetaClass, @selector(mainBundle), (IMP)CDRMainBundle, "v@:");
            }
        }
        [pool drain];
    }
}

@end

@implementation CDROTestIPhoneRunner {
    UIWindow *window_;
}

void CDRRunTests(id self, SEL _cmd, id ignored) {
    CDROTestIPhoneRunner *runner = [[CDROTestIPhoneRunner alloc] init];
    [runner runAllTestsWithTestProbe:self];
}

+ (void)load {
    CDRInjectIntoXCTestRunner();
//    CDRHijackOCUnitAndXCTestRun((IMP)CDRRunTests);
}

- (void)runAllTestsWithTestProbe:(id)testProbe {
    [self runStandardTestsWithTestProbe:testProbe];

    BOOL isCedarApp = [[UIApplication sharedApplication] isKindOfClass:[CedarApplication class]];
    BOOL isCedarDelegate = [[[UIApplication sharedApplication] delegate] isKindOfClass:[CedarApplicationDelegate class]];

    if (!isCedarApp && !isCedarDelegate) {
        [self runSpecsAndExit];
    }
}

- (void)runSpecsAndExit {
    if (getenv("CEDAR_GUI_SPECS")) {
        NSLog(@"CEDAR_GUI_SPECS is no longer supported");
    }
    [self runSpecs];
    [self exitWithAggregateStatus];
}

- (void)exitWithStatus:(int)status {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(_terminateWithStatus:)]) {
        [application _terminateWithStatus:status];
    } else {
        [super exitWithStatus:status];
    }
}

@end
