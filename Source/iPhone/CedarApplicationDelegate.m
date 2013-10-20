#import "CedarApplicationDelegate.h"
#import "CDRExampleReporterViewController.h"
#import "HeadlessSimulatorWorkaround.h"
#import "CDRFunctions.h"
#import <objc/runtime.h>

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

- (UIWindow *)window {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"This Cedar iOS spec suite is run with the CedarApplicationDelegate.  If your code needs the UIApplicationDelegate's window, you should stub this method to return an appropriate window."
                                 userInfo:nil];
}

@end
