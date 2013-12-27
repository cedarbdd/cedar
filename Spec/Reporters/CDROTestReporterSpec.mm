#if TARGET_OS_IPHONE
// Normally you would include this file out of the framework.  However, we're
// testing the framework here, so including the file from the framework will
// conflict with the compiler attempting to include the file from the project.
#import "SpecHelper.h"
#else
#import <Cedar/SpecHelper.h>
#endif

#import "CDROTestReporter.h"
#import "CDRExampleGroup.h"
#import "CDRExample.h"
#import "CDRReportDispatcher.h"

static NSMutableString *testReporterLog;

@interface CDROTestReporter (Protected)
- (void)logMessage:(NSString *)message;
@end

@implementation CDROTestReporter (SpecOverrides)
- (void)logMessage:(NSString *)message {
    [testReporterLog appendFormat:@"%@\n", message];
}
@end

@interface MyExampleSpec : CDRSpec
@end

@implementation MyExampleSpec
- (void)declareBehaviors {}
@end

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CDROTestReporterSpec)

describe(@"CDROTestReporter", ^{
    __block CDROTestReporter *reporter;
    __block CDRSpec *spec1, *spec2;
    __block CDRExampleGroup *group1, *group2;
    __block CDRExample *passingExample, *failingExample;
    __block NSString *bundleName;
    __block CDRReportDispatcher *dispatcher;

    beforeEach(^{
        bundleName = [NSBundle mainBundle].bundleURL.pathComponents.lastObject;

        // Running as the test suite should not really happen for
        // this test reporter, but we'll allow it for our test
        // suite.
        if ([@[@"Debug", @"Release"] containsObject:bundleName]) {
            bundleName = @"Cedar.framework";
        }

        testReporterLog = [NSMutableString string];
        reporter = [[[CDROTestReporter alloc] init] autorelease];
        dispatcher = [[[CDRReportDispatcher alloc] initWithReporters:@[reporter]] autorelease];

        spec1 = [[[CDRSpec alloc] init] autorelease];
        spec2 = [[[MyExampleSpec alloc] init] autorelease];
        group1 = [CDRExampleGroup groupWithText:@"my group"];
        group1.spec = spec1;
        group2 = [CDRExampleGroup groupWithText:@"my group other"];
        group2.spec = spec1;
        passingExample = [CDRExample exampleWithText:@"passing" andBlock:^{}];
        passingExample.spec = spec1;
        failingExample = [CDRExample exampleWithText:@"failing" andBlock:^{fail(@"whale");}];
        failingExample.spec = spec1;
    });

    afterEach(^{
        testReporterLog = nil;
    });

    describe(@"starting the test run", ^{
        beforeEach(^{
            [dispatcher runWillStartWithGroups:@[group1] andRandomSeed:1337];
        });

        it(@"should report the random seed", ^{
            testReporterLog should contain(@"Cedar Random Seed: 1337");
        });

        it(@"should report the 'Cedar Tests' suite", ^{
            testReporterLog should contain(@"Test Suite 'Cedar Tests' started at");
        });

        it(@"should reporter the test bundle suite", ^{
            testReporterLog should contain([NSString stringWithFormat:@"Test Suite '%@' started at", bundleName]);
        });
    });

    describe(@"processing an example", ^{
        beforeEach(^{
            [group1 add:passingExample];
            [group1 add:failingExample];
            [spec1.rootGroup add:group1];
            [dispatcher runWillStartWithGroups:@[spec1.rootGroup] andRandomSeed:1337];
            testReporterLog = [NSMutableString string];

            [group1 runWithDispatcher:dispatcher];
        });

        it(@"should report the spec class", ^{
            testReporterLog should contain(@"Test Suite 'CDRSpec' started at");
        });

        it(@"should report the spec class finishing after the run completes", ^{
            [dispatcher runDidComplete];

            testReporterLog should contain(@"Test Suite 'CDRSpec' finished at");
            testReporterLog should contain(@"Executed 2 tests, with 1 failure (0 unexpected) in");
        });

        it(@"should report the passing example", ^{
            testReporterLog should contain(@"Test Case '-[CDRSpec my_group_passing]' started.");
        });

        it(@"should finish the passing example", ^{
            testReporterLog should contain(@"Test Case '-[CDRSpec my_group_passing]' passed (0.000 seconds).");
        });

        it(@"should report the passing example", ^{
            testReporterLog should contain(@"Test Case '-[CDRSpec my_group_failing]' started.");
        });

        it(@"should finish the passing example", ^{
            testReporterLog should contain(@"Test Case '-[CDRSpec my_group_failing]' failed (0.000 seconds).");
        });
    });

    describe(@"processing multiple spec classes", ^{
        beforeEach(^{
            [group1 add:passingExample];
            [group1 add:failingExample];
            [spec1.rootGroup add:group1];

            CDRExample *pendingExample = [CDRExample exampleWithText:@"pending" andBlock:nil];
            pendingExample.spec = spec2;
            [group2 add:pendingExample];
            [spec2.rootGroup add:group2];

            [dispatcher runWillStartWithGroups:@[spec1.rootGroup, spec2.rootGroup] andRandomSeed:1337];
            testReporterLog = [NSMutableString string];

            [group1 runWithDispatcher:dispatcher];
            [group2 runWithDispatcher:dispatcher];
        });

        it(@"should report the spec class", ^{
            testReporterLog should contain(@"Test Suite 'CDRSpec' started at");
        });

        it(@"should report the spec class finishing after the run completes", ^{
            [dispatcher runDidComplete];

            testReporterLog should contain(@"Test Suite 'CDRSpec' finished at");
            testReporterLog should contain(@"Executed 2 tests, with 1 failure (0 unexpected) in");
        });

        it(@"should report the passing example", ^{
            testReporterLog should contain(@"Test Case '-[CDRSpec my_group_passing]' started.");
        });

        it(@"should finish the passing example", ^{
            testReporterLog should contain(@"Test Case '-[CDRSpec my_group_passing]' passed (0.000 seconds).");
        });

        it(@"should report the passing example", ^{
            testReporterLog should contain(@"Test Case '-[CDRSpec my_group_failing]' started.");
        });

        it(@"should finish the passing example", ^{
            testReporterLog should contain(@"Test Case '-[CDRSpec my_group_failing]' failed (0.000 seconds).");
        });

        it(@"should report the pending example", ^{
            testReporterLog should contain(@"Test Case '-[MyExampleSpec my_group_other_pending]' started.");
        });

        it(@"should finish the pending example", ^{
            testReporterLog should contain(@"Test Case '-[MyExampleSpec my_group_other_pending]' pending (0.000 seconds).");
        });
    });

    describe(@"finishing the run", ^{
        beforeEach(^{
            [dispatcher runWillStartWithGroups:@[group1] andRandomSeed:1337];
            testReporterLog = [NSMutableString string];
            [dispatcher runDidComplete];
        });

        it(@"should report the 'Cedar Tests' suite", ^{
            testReporterLog should contain(@"Test Suite 'Cedar Tests' finished at");
        });

        it(@"should reporter the test bundle suite", ^{
            testReporterLog should contain([NSString stringWithFormat:@"Test Suite '%@' finished at", bundleName]);
        });
    });
});

SPEC_END
