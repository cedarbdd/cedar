#import "Cedar.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface TestCDRDefaultReporter : CDRDefaultReporter
@property (nonatomic, retain) NSMutableString *reporter_output;
@end

@implementation TestCDRDefaultReporter

- (instancetype)initWithCedarVersion:(NSString *)cedarVersionString {
    if (self = [super initWithCedarVersion:cedarVersionString]) {
        self.reporter_output = [NSMutableString string];
    }
    return self;
}

- (void)dealloc {
    self.reporter_output = nil;
    [super dealloc];
}

- (void)logText:(NSString *)linePartial {
    [self.reporter_output appendString:linePartial];
}

@end

SPEC_BEGIN(CDRDefaultReporterSpec)

describe(@"CDRDefaultReporter", ^{
    __block TestCDRDefaultReporter *reporter;
    NSString *cedarVersionString = @"0.1.2 (a71e8f)";

    beforeEach(^{
        reporter = [[[TestCDRDefaultReporter alloc] initWithCedarVersion:cedarVersionString] autorelease];
    });

    describe(@"starting the test run", ^{
        beforeEach(^{
            [reporter runWillStartWithGroups:@[] andRandomSeed:1234];
        });

        it(@"should report the Cedar version", ^{
            reporter.reporter_output should contain([NSString stringWithFormat:@"Cedar Version: %@", cedarVersionString]);
        });

        it(@"should report the random seed", ^{
            reporter.reporter_output should contain(@"Running With Random Seed: 1234");
        });
    });

    context(@"when adding one group", ^{
        __block CDRExampleGroup *group;

        beforeEach(^{
            group = [[[CDRExampleGroup alloc] initWithText:@"example group" isRoot:YES] autorelease];
        });

        context(@"with one child 'it' example", ^{
            it(@"exampleCount should be 1", ^{
                CDRExample *example = [[[CDRExample alloc] initWithText:@"example" andBlock:^{ }] autorelease];
                [group add:example];

                [reporter runWillStartWithGroups:@[group] andRandomSeed:33];
                [reporter runWillStartExampleGroup:group];
                [reporter runWillStartExample:example];
                [example runWithDispatcher:nil];
                [reporter runDidFinishExample:example];
                [reporter runDidFinishExampleGroup:group];
                [reporter runDidComplete];
                [reporter exampleCount] should equal(1);
            });
        });

        context(@"with no child 'it' examples", ^{
            it(@"exampleCount should be 0", ^{
                [reporter runWillStartWithGroups:@[group] andRandomSeed:33];
                [reporter runDidComplete];
                [reporter exampleCount] should equal(0);
            });
        });
    });
});

SPEC_END
