#if TARGET_OS_IPHONE
// Normally you would include this file out of the framework.  However, we're
// testing the framework here, so including the file from the framework will
// conflict with the compiler attempting to include the file from the project.
#import "SpecHelper.h"
#else
#import <Cedar/SpecHelper.h>
#endif

#import "CDRExample.h"
#import "CDRExampleGroup.h"
#import "CDRDefaultReporter.h"
#import <cstdio>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface TestCDRDefaultReporter : CDRDefaultReporter
@end

@implementation TestCDRDefaultReporter
- (void)runWillStartWithGroups:(NSArray *)groups andRandomSeed:(unsigned int)seed {
    FILE *realStdout = stdout;
    stdout = fopen("/dev/null", "w");

    @try {
        [super runWillStartWithGroups:groups andRandomSeed:seed];
    }
    @finally {
        fclose(stdout);
        stdout = realStdout;
    }
}

- (void)runDidComplete {
    FILE *realStdout = stdout;
    stdout = fopen("/dev/null", "w");

    @try {
        [super runDidComplete];
    }
    @finally {
        fclose(stdout);
        stdout = realStdout;
    }
}
@end

SPEC_BEGIN(CDRDefaultReporterSpec)

describe(@"CDRDefaultReporter", ^{
    __block TestCDRDefaultReporter *reporter;

    beforeEach(^{
        reporter = [[[TestCDRDefaultReporter alloc] init] autorelease];
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
