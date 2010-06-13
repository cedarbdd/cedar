#import <Cedar/SpecHelper.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

SPEC_BEGIN(CppSpecSpec)

describe(@"CppSpec", ^{
    describe(@"Expectations", ^{
        describe(@"with built-in types", ^{
            __block int expectedValue;

            beforeEach(^ {
                expectedValue = 1;
            });

            it(@"should run", ^{
//                assertThatInt(1, equalToInt(expectedValue));
            });
        });
    });
});

SPEC_END
