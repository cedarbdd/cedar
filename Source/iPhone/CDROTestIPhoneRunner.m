#import <UIKit/UIKit.h>
#import "CDROTestIPhoneRunner.h"
#import "CDROTestHelper.h"
#import "CedarApplicationDelegate.h"
#import "HeadlessSimulatorWorkaround.h"
#import "CDRFunctions.h"
#import "CDRExampleReporterViewController.h"
#import <objc/runtime.h>

@interface UIApplication (PrivateAppleMethods)
- (void)_terminateWithStatus:(int)status;
@end

@implementation NSBundle (MainBundleHijack)
static NSBundle *mainBundle__ = nil;

NSBundle *CDRMainBundle(id self, SEL _cmd) {
    return mainBundle__;
}

+ (void)load {
    setUpFakeWorkspaceIfRequired();

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
    CDRExampleReporterViewController *viewController_;
}

void CDRRunTests(id self, SEL _cmd, id ignored) {
    CDROTestIPhoneRunner *runner = [[CDROTestIPhoneRunner alloc] init];
    [runner runAllTestsWithTestProbe:self];
}

+ (void)load {
    CDRHijackOCUnitAndXCTestRun((IMP)CDRRunTests);
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
        window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

        viewController_ = [[CDRExampleReporterViewController alloc] init];
        [window_ addSubview:viewController_.view];

        [window_ makeKeyAndVisible];
    } else {
        [self runSpecs];
        [self exitWithAggregateStatus];
    }
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
