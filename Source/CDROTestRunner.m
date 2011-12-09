#import "CDROTestRunner.h"
#import "CDRFunctions.h"
#import <objc/runtime.h>

@implementation CDROTestRunner

int runOCUnitTests(id self, SEL _cmd, id ignored) {
    BOOL hasFailed  = NO;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    [[NSBundle allFrameworks] makeObjectsPerformSelector:@selector(principalClass)];
    // [SenTestObserver class];
    hasFailed = !(BOOL)[[[self performSelector:@selector(specifiedTestSuite)] performSelector:@selector(run)] performSelector:@selector(hasSucceeded)];
    [pool release];

    return (int)hasFailed;
}

void runTests(id self, SEL _cmd, id ignored) {
    int exitStatus = runOCUnitTests(self, _cmd, ignored);

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Since we want to have integration with XCode when running tests from inside the IDE
    // CDROTestReporter needs to be default reporter; however, we can use any other reporter
    // when running from the command line (e.g. CDRColorizedReporter).
    Class reporterClass = CDRReporterClassFromEnv("CDROTestReporter");
    if (!reporterClass) {
        exit(-999);
    }

    id<CDRExampleReporter> reporter = [[[reporterClass alloc] init] autorelease];
    exitStatus |= runSpecsWithCustomExampleReporter(reporter);

    // otest always returns 0 as its exit code even if any test fails;
    // we need to forcibly exit with correct exit code to make CI happy.
    [pool drain];

    exit(exitStatus);
}

// Hijack SenTestProble runTests: class method and run our specs instead.
// See https://github.com/jy/SenTestingKit for more information.
+ (void)load {
    Class senTestProbeClass = objc_getClass("SenTestProbe");
    if (senTestProbeClass) {
        Class senTestProbeMetaClass = objc_getMetaClass("SenTestProbe");
        class_replaceMethod(senTestProbeMetaClass, @selector(runTests:), (IMP)runTests, "v@:@");
    }
}

@end
