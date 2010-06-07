#import "CedarApplicationDelegate.h"
#import "CDRExampleRunnerViewController.h"

@implementation CedarApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    viewController_ = [[CDRExampleRunnerViewController alloc] init];
    [window_ addSubview:viewController_.view];
    [window_ makeKeyAndVisible];

    return NO;
}

@end
