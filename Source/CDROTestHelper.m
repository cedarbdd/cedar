#import "CDROTestHelper.h"
#import <objc/runtime.h>

// This is exact copy of SenTestProbe +runTests: (https://github.com/jy/SenTestingKit/blob/master/SenTestProbe.m)
// except that it does not call exit() at the end.
int CDRRunOCUnitTests(id self, SEL _cmd, id ignored) {
    BOOL hasFailed = NO;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    [[NSBundle allFrameworks] makeObjectsPerformSelector:@selector(principalClass)];
    [NSClassFromString(@"SenTestObserver") class];
    [NSClassFromString(@"XCTestObserver") class];

    SEL specifiedTestSuiteSelector = NSSelectorFromString(@"specifiedTestSuite");
    SEL hasSucceededSelector = NSSelectorFromString(@"hasSucceeded");
    id testSuite = [self performSelector:specifiedTestSuiteSelector];
    id runResult = [testSuite performSelector:@selector(run)];
    hasFailed = !(BOOL)[runResult performSelector:hasSucceededSelector];

    [pool release];
    return (int)hasFailed;
}

// Hijack SenTestProble runTests: class method and run our specs instead.
// See https://github.com/jy/SenTestingKit for more information.
void CDRHijackOCUnitRun(IMP newImplementation) {
    SEL runTestsSelector = NSSelectorFromString(@"runTests:");

    Class probeClass = objc_getClass("XCTestProbe");
    if (probeClass) {
        Class senTestProbeMetaClass = objc_getMetaClass("XCTestProbe");
        class_replaceMethod(senTestProbeMetaClass, runTestsSelector, newImplementation, "v@:@");
    }

    probeClass = objc_getClass("SenTestProbe");
    if (probeClass) {
        Class senTestProbeMetaClass = objc_getMetaClass("SenTestProbe");
        class_replaceMethod(senTestProbeMetaClass, runTestsSelector, newImplementation, "v@:@");
    }
}
