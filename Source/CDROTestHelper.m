#import "CDROTestHelper.h"
#import <objc/runtime.h>

FOUNDATION_EXPORT int XCTSelfTestMain(void);

id CDRPerformSelector(id obj, NSString *selectorString) {
    SEL selector = NSSelectorFromString(selectorString);
    return [obj performSelector:selector];
}

// This is exact copy of SenTestProbe +runTests: (https://github.com/jy/SenTestingKit/blob/master/SenTestProbe.m)
// except that it does not call exit() at the end.
int CDRRunOCUnitTests(id self, SEL _cmd, id ignored) {
    BOOL hasFailed = NO;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    [[NSBundle allFrameworks] makeObjectsPerformSelector:@selector(principalClass)];
    // ensure observers are loaded
    [NSClassFromString(@"SenTestObserver") class];

    id testSuite = CDRPerformSelector(self, @"specifiedTestSuite");
    id runResult = [testSuite performSelector:@selector(run)];
    hasFailed = !(BOOL)CDRPerformSelector(runResult, @"hasSucceeded");

    [pool release];
    return (int)hasFailed;
}

// Hijack SenTestProble runTests: class method and run our specs instead.
// See https://github.com/jy/SenTestingKit for more information.
void CDRHijackOCUnitRun(IMP newImplementation) {
    SEL runTestsSelector = NSSelectorFromString(@"runTests:");

    Class probeClass = objc_getClass("SenTestProbe");
    if (probeClass) {
        Class senTestProbeMetaClass = objc_getMetaClass("SenTestProbe");
        class_replaceMethod(senTestProbeMetaClass, runTestsSelector, newImplementation, "v@:@");
    }
}

// Replicates the code in +[XCTestProbe runTests:]
int CDRRunXCUnitTests(id self, SEL _cmd, id ignored) {
    BOOL hasFailed = NO;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    [[NSBundle allFrameworks] makeObjectsPerformSelector:@selector(principalClass)];
    // ensure observers are loaded
    [NSClassFromString(@"SenTestObserver") class];

    id xcTestObserverClass = objc_getClass("XCTestObserver");
    CDRPerformSelector(xcTestObserverClass, @"setUpTestObservers");
    CDRPerformSelector(xcTestObserverClass, @"resumeObservation");

    id testSuite = CDRPerformSelector(self, @"specifiedTestSuite");
    id runResult = [testSuite performSelector:@selector(run)];
    hasFailed = !(BOOL)CDRPerformSelector(runResult, @"hasSucceeded");

    CDRPerformSelector(xcTestObserverClass, @"suspendObservation");
    CDRPerformSelector(xcTestObserverClass, @"tearDownTestObservers");

    [pool release];
    return (int)hasFailed;
}

void CDRHijackXCUnitRun(IMP newImplementation) {
    SEL runTestsSelector = NSSelectorFromString(@"runTests:");

    Class probeClass = objc_getClass("XCTestProbe");
    if (probeClass) {
        Class xcTestProbeMetaClass = objc_getMetaClass("XCTestProbe");
        class_replaceMethod(xcTestProbeMetaClass, runTestsSelector, newImplementation, "v@:@");
    }
}
