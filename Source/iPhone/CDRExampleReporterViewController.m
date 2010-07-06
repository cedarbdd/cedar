#import "CDRExampleReporterViewController.h"
#import "CDRFunctions.h"
#import "CDRSpecStatusViewController.h"
#import "CDRDefaultReporter.h"

@implementation CDRExampleReporterViewController

#pragma mark View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

    if (getenv("CEDAR_HEADLESS_SPECS")) {
        id<CDRExampleReporter> reporter = [[[CDRDefaultReporter alloc] init] autorelease];
        runSpecsWithCustomExampleReporter(NULL, reporter);
        exit([reporter result]);
    } else {
        [self performSelectorInBackground:@selector(startSpecs) withObject:NULL];
    }
}

- (void)viewDidUnload {

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)startSpecs {
    runSpecsWithCustomExampleReporter(NULL, self);
}

- (void)pushRootSpecStatusController:(NSArray *)groups {
    UIViewController *rootController = [[CDRSpecStatusViewController alloc] initWithExamples:groups];
    [self pushViewController:rootController animated:NO];
    [rootController release];
}

#pragma mark CDRExampleReporter
- (void)runWillStartWithGroups:(NSArray *)groups {
    // The specs run on a background thread, so callbacks from the runner will
    // arrive on that thread.  We need to push the event to the main thread in
    // order to update the UI.
    [self performSelectorOnMainThread:@selector(pushRootSpecStatusController:) withObject:groups waitUntilDone:NO];
}

- (void)runDidComplete {
}

- (int)result {
  return 0;
}

@end

