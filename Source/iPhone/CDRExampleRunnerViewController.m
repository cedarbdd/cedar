#import "CDRExampleRunnerViewController.h"
#import "CDRFunctions.h"
#import "CDRSpecStatusViewController.h"

@implementation CDRExampleRunnerViewController

#pragma mark View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self performSelectorInBackground:@selector(startSpecs) withObject:NULL];
}

- (void)viewDidUnload {

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)startSpecs {
    runSpecsWithCustomExampleRunner(NULL, self);
}

- (void)pushRootSpecStatusController:(NSArray *)groups {
    UIViewController *rootController = [[CDRSpecStatusViewController alloc] initWithExamples:groups];
    [self pushViewController:rootController animated:NO];
    [rootController release];
}

#pragma mark CDRExampleRunner
- (void)runWillStartWithGroups:(NSArray *)groups {
    // Background thread.
    [self performSelectorOnMainThread:@selector(pushRootSpecStatusController:) withObject:groups waitUntilDone:NO];
}

- (void)exampleSucceeded:(CDRExample *)example {
}

- (void)example:(CDRExample *)example failedWithMessage:(NSString *)message {
}

- (void)example:(CDRExample *)example threwException:(NSException *)exception {
}

- (void)exampleThrewError:(CDRExample *)example {
}

- (void)examplePending:(CDRExample *)example {
}

- (int)result {
  return 0;
}

@end

