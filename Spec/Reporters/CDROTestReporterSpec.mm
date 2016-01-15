#import "Cedar.h"
#import "CDRReportDispatcher.h"
#import <objc/runtime.h>


static char *testReporterLogKey;

@interface CDROTestReporter (SpecOverrides)
- (void)logMessage:(NSString *)message;
- (NSMutableString *)reporter_output;
- (void)setReporter_output:(NSMutableString *)value;
@end

@implementation CDROTestReporter (SpecOverrides)

- (void)logMessage:(NSString *)message {
    [self.reporter_output appendFormat:@"%@\n", message];
}

- (NSMutableString *)reporter_output {
    return objc_getAssociatedObject(self, &testReporterLogKey);
}

- (void)setReporter_output:(NSMutableString *)value {
    objc_setAssociatedObject(self, &testReporterLogKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
    __block CDRExampleGroup *group1, *group2, *focusedGroup;
    __block CDRExample *passingExample, *failingExample, *focusedExample;
    __block NSString *bundleName;
    __block CDRReportDispatcher *dispatcher;
    NSString *cedarVersionString = @"0.1.2 (a71e8f)";

    beforeEach(^{
        bundleName = [NSBundle mainBundle].bundleURL.pathComponents.lastObject;

        reporter = [[[CDROTestReporter alloc] initWithCedarVersion:cedarVersionString] autorelease];
        reporter.reporter_output = [NSMutableString string];
        dispatcher = [[[CDRReportDispatcher alloc] initWithReporters:@[reporter]] autorelease];

        spec1 = [[[CDRSpec alloc] init] autorelease];
        spec2 = [[[MyExampleSpec alloc] init] autorelease];
        group1 = [CDRExampleGroup groupWithText:@"my group"];
        group1.spec = spec1;
        group2 = [CDRExampleGroup groupWithText:@"my group other"];
        group2.spec = spec2;
        passingExample = [CDRExample exampleWithText:@"passing" andBlock:^{}];
        passingExample.spec = spec1;
        failingExample = [CDRExample exampleWithText:@"failing" andBlock:^{fail(@"whale");}];
        failingExample.spec = spec1;

        focusedGroup = [CDRExampleGroup groupWithText:@"laser"];
        focusedExample = [CDRExample exampleWithText:@"focus" andBlock:^{}];
        focusedGroup.focused = YES;
        [focusedGroup add:focusedExample];
        focusedGroup.spec = spec1;
    });

    afterEach(^{
        reporter.reporter_output = nil;
    });

    describe(@"starting the test run", ^{
        context(@"when not focused", ^{
            beforeEach(^{
                [dispatcher runWillStartWithGroups:@[group1] andRandomSeed:1337];
            });

            it(@"should report the Cedar version", ^{
                reporter.reporter_output should contain([NSString stringWithFormat:@"Cedar Version: %@", cedarVersionString]);
            });

            it(@"should report the random seed", ^{
                reporter.reporter_output should contain(@"Cedar Random Seed: 1337");
            });

            it(@"should report that all tests are running", ^{
                reporter.reporter_output should contain(@"Test Suite 'All tests' started at");
            });

            it(@"should report the test bundle suite", ^{
                reporter.reporter_output should contain([NSString stringWithFormat:@"Test Suite '%@' started at", bundleName]);
            });
        });

        context(@"when focused", ^{
            __block BOOL originalState;

            beforeEach(^{
                originalState = [CDRSpecHelper specHelper].shouldOnlyRunFocused;
                [CDRSpecHelper specHelper].shouldOnlyRunFocused = YES;

                [dispatcher runWillStartWithGroups:@[focusedGroup] andRandomSeed:34];
            });

            afterEach(^{
                [CDRSpecHelper specHelper].shouldOnlyRunFocused = originalState;
            });

            it(@"should report the Cedar version", ^{
                reporter.reporter_output should contain([NSString stringWithFormat:@"Cedar Version: %@", cedarVersionString]);
            });

            it(@"should report the random seed", ^{
                reporter.reporter_output should contain(@"Cedar Random Seed: 34");
            });

            it(@"should report that a subset of tests are running", ^{
                reporter.reporter_output should contain(@"Test Suite 'Multiple Selected Tests' started at");
            });

            it(@"should report the test bundle suite", ^{
                reporter.reporter_output should contain([NSString stringWithFormat:@"Test Suite '%@' started at", bundleName]);
            });
        });
    });

    describe(@"finishing the run", ^{
        context(@"when not focused", ^{
            beforeEach(^{
                [dispatcher runWillStartWithGroups:@[group1] andRandomSeed:1337];
                reporter.reporter_output = [NSMutableString string];
                [dispatcher runDidComplete];
            });

            it(@"should report the end of all the tests", ^{
                reporter.reporter_output should contain(@"Test Suite 'All tests' finished at");
            });

            it(@"should report the test bundle suite stats", ^{
                reporter.reporter_output should contain([NSString stringWithFormat:@"Test Suite '%@' finished at", bundleName]);
            });
        });

        context(@"when focused", ^{
            __block BOOL originalState;
            beforeEach(^{
                originalState = [CDRSpecHelper specHelper].shouldOnlyRunFocused;
                [CDRSpecHelper specHelper].shouldOnlyRunFocused = YES;

                [dispatcher runWillStartWithGroups:@[focusedGroup] andRandomSeed:42];
                reporter.reporter_output = [NSMutableString string];
                [dispatcher runDidComplete];
            });

            afterEach(^{
                [CDRSpecHelper specHelper].shouldOnlyRunFocused = originalState;
            });

            it(@"should report the end of all the tests", ^{
                reporter.reporter_output should contain(@"Test Suite 'Multiple Selected Tests' finished at");
            });

            it(@"should report the test bundle suite stats", ^{
                reporter.reporter_output should contain([NSString stringWithFormat:@"Test Suite '%@' finished at", bundleName]);
            });

        });
    });

    describe(@"processing an example", ^{
        beforeEach(^{
            [group1 add:passingExample];
            [group1 add:failingExample];
            [spec1.rootGroup add:group1];
            [dispatcher runWillStartWithGroups:@[spec1.rootGroup] andRandomSeed:1337];
            reporter.reporter_output = [NSMutableString string];

            [group1 runWithDispatcher:dispatcher];
        });

        it(@"should report the spec class", ^{
            reporter.reporter_output should contain(@"Test Suite 'CDRSpec' started at");
        });

        it(@"should report the spec class finishing after the run completes", ^{
            [dispatcher runDidComplete];

            reporter.reporter_output should contain(@"Test Suite 'CDRSpec' finished at");
            reporter.reporter_output should contain(@"Executed 2 tests, with 1 failure (0 unexpected) in");
        });

        it(@"should report the passing example", ^{
            reporter.reporter_output should contain(@"Test Case '-[CDRSpec my_group_passing]' started.");
        });

        it(@"should finish the passing example", ^{
            reporter.reporter_output should contain(@"Test Case '-[CDRSpec my_group_passing]' passed (");
        });

        it(@"should report the passing example", ^{
            reporter.reporter_output should contain(@"Test Case '-[CDRSpec my_group_failing]' started.");
        });

        it(@"should finish the passing example", ^{
            reporter.reporter_output should contain(@"Test Case '-[CDRSpec my_group_failing]' failed (");
        });
    });

    describe(@"processing multiple spec classes", ^{
        beforeEach(^{
            [group1 add:passingExample];
            CDRExampleGroup *anotherPassing = [CDRExample exampleWithText:@"another_passing" andBlock:^{}];
            anotherPassing.spec = spec1;
            [group1 add:anotherPassing];
            [spec1.rootGroup add:group1];

            [group2 add:failingExample];
            group2.spec = spec2;
            failingExample.spec = spec2;

            CDRExample *pendingExample = [CDRExample exampleWithText:@"pending" andBlock:nil];
            pendingExample.spec = spec2;
            [group2 add:pendingExample];
            [spec2.rootGroup add:group2];

            [dispatcher runWillStartWithGroups:@[spec1.rootGroup, spec2.rootGroup] andRandomSeed:1337];
            reporter.reporter_output = [NSMutableString string];

            [group1 runWithDispatcher:dispatcher];
            [group2 runWithDispatcher:dispatcher];
        });

        it(@"should report the spec class", ^{
            reporter.reporter_output should contain(@"Test Suite 'CDRSpec' started at");
        });

        it(@"should report the passing example", ^{
            reporter.reporter_output should contain(@"Test Case '-[CDRSpec my_group_passing]' started.");
        });

        it(@"should finish the passing example", ^{
            reporter.reporter_output should contain(@"Test Case '-[CDRSpec my_group_passing]' passed");
        });

        it(@"should report the spec class finishing after the run completes", ^{
            [dispatcher runDidComplete];

            reporter.reporter_output should contain(@"Test Suite 'CDRSpec' finished at");

            NSRange range = [reporter.reporter_output rangeOfString:@"Test Suite 'CDRSpec' finished at"];
            [reporter.reporter_output substringFromIndex:range.location] should contain(@"Executed 3 tests, with 1 failure (0 unexpected) in");
        });

        it(@"should report the failing example", ^{
            reporter.reporter_output should contain(@"Test Case '-[MyExampleSpec my_group_other_failing]' started.");
        });

        it(@"should report the failing example's error", ^{
            reporter.reporter_output should contain(@": error: -[MyExampleSpec my_group_other_failing] :");
        });

        it(@"should finish the failing example", ^{
            reporter.reporter_output should contain(@"Test Case '-[MyExampleSpec my_group_other_failing]' failed");
        });

        it(@"should not report the pending example", ^{
            reporter.reporter_output should_not contain(@"Test Case '-[MyExampleSpec my_group_other_pending]'");
        });
    });
});

SPEC_END
