#define HC_SHORTHAND
#if TARGET_OS_IPHONE
#import <Cedar/SpecHelper.h>
#import "OCMock.h"
#import "OCHamcrest.h"
#else
#import <Cedar/SpecHelper.h>
#import <OCMock/OCMock.h>
#import <OCHamcrest/OCHamcrest.h>
#endif

SPEC_BEGIN(CppSpecSpec)

describe(@"CppSpec", ^{
    describe(@"Expectations", ^{
        describe(@"with built-in types", ^{
            __block int expectedValue;

            beforeEach(^ {
//                expectedValue = 1;
            });

            it(@"should run", ^{
//                assertThatInt(1, equalToInt(expectedValue));
            });
        });
    });
});

SPEC_END
