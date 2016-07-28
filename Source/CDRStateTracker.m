#import "CDRStateTracker.h"
#import "CDRRunState.h"

@implementation CDRStateTracker

- (void)didStartPreparingTests {
    CDRSetCurrentRunState(CedarRunStatePreparingTests);
}

- (void)didStartRunningTests {
    CDRSetCurrentRunState(CedarRunStateRunningTests);
}

- (void)didFinishRunningTests {
    CDRSetCurrentRunState(CedarRunStateFinished);
}

@end
