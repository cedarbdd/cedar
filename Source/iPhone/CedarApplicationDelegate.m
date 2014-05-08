#import "CedarApplicationDelegate.h"
#import "HeadlessSimulatorWorkaround.h"
#import "CDROTestIPhoneRunner.h"

@implementation CedarApplication {
    CDROTestIPhoneRunner *_runner;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _runner = [[CDROTestIPhoneRunner alloc] init];
    [_runner runSpecsAndExit];
    return NO;
}

@end

@implementation CedarApplicationDelegate {
    CDROTestIPhoneRunner *_runner;
}

- (id)init {
    if (self = [super init]) {
        setUpFakeWorkspaceIfRequired();
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _runner = [[CDROTestIPhoneRunner alloc] init];
    [_runner runSpecsAndExit];
    return NO;
}

- (UIWindow *)window {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"This Cedar iOS spec suite is run with the CedarApplicationDelegate.  If your code needs the UIApplicationDelegate's window, you should stub this method to return an appropriate window."
                                 userInfo:nil];
}

@end
