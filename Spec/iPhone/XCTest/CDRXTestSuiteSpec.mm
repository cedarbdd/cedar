#if TARGET_OS_IPHONE
// Normally you would include this file out of the framework.  However, we're
// testing the framework here, so including the file from the framework will
// conflict with the compiler attempting to include the file from the project.
#import "CDRSpecHelper.h"
#else
#import <Cedar/CDRSpecHelper.h>
#endif

#import "CDRSpec.h"
#import "CDRXTestSuite.h"
#import "CDRReportDispatcher.h"

@interface CDR_XCTest : NSObject
- (void)performTest:(id)aRun;
@end

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CDRXTestSuiteSpec)

describe(@"CDRXTestSuite", ^{
    __block id subject;
    __block CDRReportDispatcher *dispatcher;

    static NSUInteger willStartExampleGroupCount;
    static NSUInteger didFinishExampleGroupCount;

    it(@"should report that each parent example group has started and ended to the dispatcher", ^{
        willStartExampleGroupCount = 0;
        didFinishExampleGroupCount = 0;

        dispatcher = nice_fake_for([CDRReportDispatcher class]);
        dispatcher stub_method(@selector(runWillStartExampleGroup:)).and_do_block(^(CDRExampleGroup *group){
            ++willStartExampleGroupCount;
        });
        dispatcher stub_method(@selector(runDidFinishExampleGroup:)).and_do_block(^(CDRExampleGroup *group){
            ++didFinishExampleGroupCount;
        });

        CDRSpec *simulatedSpec = [[[NSClassFromString(@"CDRXSimulatedTestSuiteSpec") alloc] init] autorelease];
        [simulatedSpec defineBehaviors];
        subject = [simulatedSpec testSuiteWithRandomSeed:0 dispatcher:dispatcher];
        [subject performTest:nil];

        willStartExampleGroupCount should equal(4);
        didFinishExampleGroupCount should equal(4);
    });
});

SPEC_END


SPEC_BEGIN(CDRXSimulatedTestSuiteSpec)

describe(@"CDRXSimulatedTestSuite", ^{
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
