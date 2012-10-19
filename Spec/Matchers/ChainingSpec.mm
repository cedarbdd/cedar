#if TARGET_OS_IPHONE
// Normally you would include this file out of the framework.  However, we're
// testing the framework here, so including the file from the framework will
// conflict with the compiler attempting to include the file from the project.
#import "SpecHelper.h"
#else
#import <Cedar/SpecHelper.h>
#endif

extern "C" {
#import "ExpectFailureWithMessage.h"
}

using namespace Cedar::Matchers;

SPEC_BEGIN(ChainingSpec)

describe(@"Chaining multiple matchers", ^{
    it(@"should pass if all matchers pass", ^{
        1 should
            be_greater_than(0),
            be_less_than(2);
    });

    it(@"should fail if at least one matcher fails", ^{
        expectFailureWithMessage(@"Expected <1> to be less than <0>", ^{
            1 should
                be_greater_than(0),
                be_less_than(0);
        });
    });

    it(@"should fail on the first failing matcher", ^{
        expectFailureWithMessage(@"Expected <1> to be greater than <2>", ^{
            1 should
                be_greater_than(2),
                be_greater_than(3);
        });
    });
});

SPEC_END
