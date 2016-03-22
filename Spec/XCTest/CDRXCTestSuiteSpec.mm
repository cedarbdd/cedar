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

        CDRSpec *simulatedSpec = [[NSClassFromString(@"CDRXCSimulatedTestSuiteSpec") alloc] init];
        [simulatedSpec defineBehaviors];
        subject = [simulatedSpec testSuiteWithRandomSeed:0 dispatcher:dispatcher];
        [subject performTest:nil];
    });

    it(@"should report that each parent example group has started and ended", ^{
        reporter.startedExampleGroups.count should equal(4);
        reporter.finishedExampleGroups.count  should equal(4);
    });

    it(@"should report that pending examples have started and ended", ^{
        NSPredicate *pendingPredicate = [NSPredicate predicateWithBlock:^BOOL(CDRExample *example, NSDictionary *_) {
            return example.state == CDRExampleStatePending;
        }];
        [reporter.startedExamples filteredArrayUsingPredicate:pendingPredicate].count should equal(2);
        [reporter.finishedExamples filteredArrayUsingPredicate:pendingPredicate].count should equal(2);
    });
});

SPEC_END


SPEC_BEGIN(CDRXCSimulatedTestSuiteSpec)

describe(@"CDRXCSimulatedTestSuite", ^{
    describe(@"with nested groups", ^{
        describe(@"lots of nested groups", ^{
            describe(@"no really, lots of nested groups", ^{
                xit(@"should report pending examples before the first test to run", ^{
                    1 should equal(2);
                });

                it(@"should start and finish each example group", ^{
                    // nothing to see here
                });

                xit(@"should report pending examples after the last test to run", ^{
                    1 should equal(2);
                });
            });
        });
    });
});

SPEC_END
