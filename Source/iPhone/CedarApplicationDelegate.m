#import "CedarApplicationDelegate.h"
#import "CDRDefaultReporter.h"
#import "CDRFunctions.h"
#import "CDRSpecStatusViewController.h"

@implementation CedarApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if(getenv("CEDAR_HEADLESS_SPECS"))
    {
        id<CDRExampleReporter> reporter = [[[CDRDefaultReporter alloc] init] autorelease];
        runSpecsWithCustomExampleReporter(NULL, reporter);
        exit([reporter result]);
        
        return NO;
    }
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    _viewController = [[UINavigationController alloc] init];
    [_window addSubview:[_viewController view]];
    [_window makeKeyAndVisible];

    [self performSelectorInBackground:@selector(startSpecs) withObject:NULL];
    
    return NO;
}

- (void)startSpecs
{
    runSpecsWithCustomExampleReporter(NULL, self);
}

- (void)pushRootSpecStatusController:(NSArray *)groups
{
    UIViewController *rootController = [[CDRSpecStatusViewController alloc] initWithExamples:groups];
    [rootController setTitle:@"Test Results"];
    [_viewController pushViewController:rootController animated:NO];
    [rootController release];
}

#pragma mark CDRExampleReporter
- (void)runWillStartWithGroups:(NSArray *)groups
{
    // The specs run on a background thread, so callbacks from the runner will
    // arrive on that thread.  We need to push the event to the main thread in
    // order to update the UI.
    [self performSelectorOnMainThread:@selector(pushRootSpecStatusController:) withObject:groups waitUntilDone:NO];
}

- (void)runDidComplete
{
}

- (int)result
{
    return 0;
}

@end
