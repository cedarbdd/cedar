#import "CDRExampleRunnerViewController.h"
#import "CDRFunctions.h"

@implementation CDRExampleRunnerViewController

#pragma mark View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    runSpecsWithCustomExampleRunner(NULL, self);
}

- (void)viewDidUnload {

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark CDRExampleRunner
- (void)runWillStartWithGroups:(NSArray *)groups {
    // TODO populate table with top-level groups.
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

