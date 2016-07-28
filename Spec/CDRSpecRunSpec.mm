#import <Cedar/Cedar.h>
#import "CDRSpecRun.h"
#import "CDRStateTracking.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CDRSpecRunSpec)

describe(@"CDRSpecRun", ^{
    __block CDRSpecRun *subject;
    __block id<CDRStateTracking, CedarDouble> stateTracker;

    beforeEach(^{
        CDRDisableSpecValidation();
    });

    afterEach(^{
        CDREnableSpecValidation();
    });

    beforeEach(^{
        stateTracker = fake_for(@protocol(CDRStateTracking));
        stateTracker stub_method(@selector(didStartPreparingTests));
        subject = [[CDRSpecRun alloc] initWithStateTracker:stateTracker
                                          exampleReporters:@[]];
    });

    it(@"should move the state into CedarRunStatePreparingTests", ^{
        stateTracker should have_received(@selector(didStartPreparingTests));
    });

    it(@"should change the state to running tests and then be finished", ^{
        stateTracker stub_method(@selector(didStartRunningTests));

        [subject performSpecRun:^{
            stateTracker should have_received(@selector(didStartRunningTests));
            stateTracker stub_method(@selector(didFinishRunningTests));
        }];

        stateTracker should have_received(@selector(didFinishRunningTests));
    });
});

SPEC_END
