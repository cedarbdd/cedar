#if TARGET_OS_IPHONE
// Normally you would include this file out of the framework.  However, we're
// testing the framework here, so including the file from the framework will
// conflict with the compiler attempting to include the file from the project.
#import "CDRSpecHelper.h"
#else
#import <Cedar/CDRSpecHelper.h>
#endif

extern "C" {
#import "ExpectFailureWithMessage.h"
}

using namespace Cedar::Matchers;

SPEC_BEGIN(ShouldSyntaxSpec)

describe(@"Should syntax", ^{
    describe(@"should", ^{
        it(@"should work with positive case", ^{
            3 should equal(3);
        });

        it(@"should work correctly with operator precendence", ^{
            1 + 2 should equal(3);
        });

        it(@"should work with negative case", ^{
            expectFailureWithMessage(@"Expected <3> to equal <4>", ^{
                3 should equal(4);
            });
        });
    });

    describe(@"should_not", ^{
        it(@"should work with positive case", ^{
            3 should_not equal(4);
        });

        it(@"should work with negative case", ^{
            expectFailureWithMessage(@"Expected <3> to not equal <3>", ^{
                3 should_not equal(3);
            });
        });
    });
});

SPEC_END
