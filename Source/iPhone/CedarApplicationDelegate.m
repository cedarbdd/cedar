#import "CedarApplicationDelegate.h"
#import "CDRExampleReporterViewController.h"
#import "HeadlessSimulatorWorkaround.h"
#import "CDRFunctions.h"
#import <objc/runtime.h>

#ifdef __IPHONE_7_0
    /* Do this only for iOS SDK 7+:
    -- Declare __gcov_flush, Grant the target process access to the supplied buffer */
    extern void __gcov_flush(void);
#endif

int runSpecsWithinUIApplication() {
    int exitStatus;

    BOOL isTestBundle = objc_getClass("SenTestProbe") || objc_getClass("XCTestProbe");

    char *defaultReporterClassName = isTestBundle ? "CDROTestReporter" : "CDRDefaultReporter";
    NSArray *reporters = CDRReportersFromEnv(defaultReporterClassName);

    if (![reporters count]) {
        exitStatus = -999;
    } else {
        exitStatus = runSpecsWithCustomExampleReporters(reporters);
    }

    return exitStatus;
}

void exitWithStatusFromUIApplication(int status) {
    UIApplication *application = [UIApplication sharedApplication];
    SEL _terminateWithStatusSelector = NSSelectorFromString(@"_terminateWithStatus:");
    if ([application respondsToSelector:_terminateWithStatusSelector]) {
        [application performSelector:_terminateWithStatusSelector withObject:(id)status];
    } else {
        exit(status);
    }
}

@implementation CedarApplication

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    viewController_ = [[CDRExampleReporterViewController alloc] init];
    [window_ addSubview:viewController_.view];
    [window_ makeKeyAndVisible];

    return NO;
}

@end

@implementation CedarApplicationDelegate

- (id)init {
    if (self = [super init]) {
        setUpFakeWorkspaceIfRequired();
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    viewController_ = [[CDRExampleReporterViewController alloc] init];
    [window_ addSubview:viewController_.view];
    [window_ makeKeyAndVisible];

    return NO;
}

- (void)applicationWillTerminate:(UIApplication *)application {
#ifdef __IPHONE_7_0
    /* Do this only for iOS SDK 7+:
    -- Make the target copy it's buffer by calling __gcov_flush */
    __gcov_flush();
#endif
}

- (UIWindow *)window {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"This Cedar iOS spec suite is run with the CedarApplicationDelegate.  If your code needs the UIApplicationDelegate's window, you should stub this method to return an appropriate window."
                                 userInfo:nil];
}

@end
