#import <UIKit/UIKit.h>
#import "CDROTestIPhoneRunner.h"
#import "CedarApplicationDelegate.h"
#import "CDRFunctions.h"
#import <objc/runtime.h>

extern int *_NSGetArgc(void);
extern char ***_NSGetArgv(void);

@implementation NSBundle (MainBundleHijack)
static NSBundle *mainBundle__ = nil;

NSBundle *mainBundle(id self, SEL _cmd) {
    return mainBundle__;
}

+ (void)load {
    if (!objc_getClass("SenTestProbe"))
        return;

    BOOL mainBundleIsApp = [[[NSBundle mainBundle] bundlePath] hasSuffix:@".app"];
    BOOL mainBundleIsOctest = [[[NSBundle mainBundle] bundlePath] hasSuffix:@".octest"];

    if (!mainBundleIsApp && !mainBundleIsOctest) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        for (NSBundle *bundle in [NSBundle allBundles]) {
            if ([[bundle bundlePath] hasSuffix:@".octest"]) {
                mainBundle__ = [bundle retain];
                Class nsBundleMetaClass = objc_getMetaClass("NSBundle");
                class_replaceMethod(nsBundleMetaClass, @selector(mainBundle), (IMP)mainBundle, "v@:");
            }
        }
        [pool drain];
    }
}

@end

@implementation CDROTestIPhoneRunner

void runTests(id self, SEL _cmd, id ignored) {
    if ([UIApplication sharedApplication]) {
        BOOL isCedarApp = [[UIApplication sharedApplication] isKindOfClass:[CedarApplication class]];
        BOOL isCedarDelegate = [[[UIApplication sharedApplication] delegate] isKindOfClass:[CedarApplicationDelegate class]];

        if (!isCedarApp && !isCedarDelegate) {
            runSpecsWithinUIApplication();
        }
    } else {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

        const char* argv[] = { "executable", "-RegisterForSystemEvents" };
        int result = UIApplicationMain(2, (char **)argv, @"CedarApplication", nil);

        [pool release];
        exit(result);
    }
}

+ (void)load {
    Class senTestProbeClass = objc_getClass("SenTestProbe");
    if (senTestProbeClass) {
        Class senTestProbeMetaClass = objc_getMetaClass("SenTestProbe");
        class_replaceMethod(senTestProbeMetaClass, @selector(runTests:), (IMP)runTests, "v@:@");
    }
}

@end
