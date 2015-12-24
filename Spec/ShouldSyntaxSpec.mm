#import "Cedar.h"
#import "ExpectFailureWithMessage.h"

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
