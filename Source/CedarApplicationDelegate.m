#import "CedarApplicationDelegate.h"
#import "Cedar.h"

@implementation CedarApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    runAllSpecs();
    return NO;
}

@end
