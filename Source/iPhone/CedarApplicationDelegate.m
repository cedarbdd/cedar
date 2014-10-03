#import "CedarApplicationDelegate.h"
#import "CDRFunctions.h"

@implementation CedarApplication

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    exit(CDRRunSpecs());
    return NO;
}

@end

@implementation CedarApplicationDelegate

- (id)init {
    if (self = [super init]) {
        CDRSuppressStandardPipesWhileLoadingClasses();
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    exit(CDRRunSpecs());
    return NO;
}

- (UIWindow *)window {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"This Cedar iOS spec suite is run with the CedarApplicationDelegate.  If your code needs the UIApplicationDelegate's window, you should stub this method to return an appropriate window."
                                 userInfo:nil];
}

@end
