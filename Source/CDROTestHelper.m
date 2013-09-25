#import "CDROTestHelper.h"
#import <objc/runtime.h>

// This is exact copy of SenTestProbe +runTests: (https://github.com/jy/SenTestingKit/blob/master/SenTestProbe.m)
// except that it does not call exit() at the end.
int CDRRunOCUnitTests(id self, SEL _cmd, id ignored) {
    BOOL hasFailed = NO;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    [[NSBundle allFrameworks] makeObjectsPerformSelector:@selector(principalClass)];
    [NSClassFromString(@"SenTestObserver") class];

    SEL specifiedTestSuiteSelector = NSSelectorFromString(@"specifiedTestSuite");
    SEL hasSucceededSelector = NSSelectorFromString(@"specifiedTestSuite");
    id testSuite = [self performSelector:specifiedTestSuiteSelector];
    id runResult = [testSuite performSelector:@selector(run)];
    hasFailed = !(BOOL)[runResult performSelector:hasSucceededSelector];

    [pool release];
    return (int)hasFailed;
}

// Hijack SenTestProble runTests: class method and run our specs instead.
// See https://github.com/jy/SenTestingKit for more information.
void CDRHijackOCUnitRun(IMP newImplementation) {
    Class senTestProbeClass = objc_getClass("SenTestProbe");
    if (senTestProbeClass) {
        Class senTestProbeMetaClass = objc_getMetaClass("SenTestProbe");
        SEL runTestsSelector = NSSelectorFromString(@"runTests:");
        class_replaceMethod(senTestProbeMetaClass, runTestsSelector, newImplementation, "v@:@");
    }
}
