#import "Cedar.h"
#import "CDRXCTestSuite.h"
#import "CDRReportDispatcher.h"
#import "CDRXCTestSupport.h"
#import "TestReporter.h"

#if !__has_feature(objc_arc)
#error This class must be compiled with ARC.
#endif

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CDRXCTestSuiteSpec)

describe(@"CDRXCTestSuite", ^{
    __block id subject;
    __block TestReporter *reporter;
    __block CDRReportDispatcher *dispatcher;

    beforeEach(^{
        reporter = [TestReporter new];
        dispatcher = [[CDRReportDispatcher alloc] initWithReporters:@[reporter]];
    });

    it(@"should report that each parent example group has started and ended", ^{
        CDRSpec *simulatedSpec = [[NSClassFromString(@"CDRXCSimulatedTestSuiteSpec") alloc] init];
        [simulatedSpec defineBehaviors];
        subject = [simulatedSpec testSuiteWithRandomSeed:0 dispatcher:dispatcher];
        [subject performTest:nil];

        reporter.startedExampleGroups.count should equal(4);
        reporter.finishedExampleGroups.count  should equal(4);
    });
});

SPEC_END


SPEC_BEGIN(CDRXCSimulatedTestSuiteSpec)

describe(@"CDRXCSimulatedTestSuite", ^{
    describe(@"with nested groups", ^{
        describe(@"lots of nested groups", ^{
            describe(@"no really, lots of nested groups", ^{
                it(@"should start and finish each example group", ^{
                    // nothing to see here
                });
            });
        });
    });
});

SPEC_END
