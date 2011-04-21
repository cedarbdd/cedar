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

using namespace Cedar::Matchers;

SPEC_BEGIN(CppSpecSpec)

describe(@"CppSpec", ^{
    describe(@"Expectations", ^{
        describe(@"with built-in types", ^{
            __block int expectedValue;

            beforeEach(^ {
                expectedValue = 1;
            });

            it(@"should run", ^{
                expect(1).toEqual(expectedValue);
            });
        });

        describe(@"with NSObject-based types", ^{
            __block NSObject *expectedValue;
            int someInteger = 7;

            beforeEach(^ {
                expectedValue = [NSString stringWithFormat:@"Value: %d", someInteger];
            });

            it(@"should run", ^{
                NSObject *actualValue = [NSString stringWithFormat:@"Value: %d", someInteger];
                expect(actualValue).toEqual(expectedValue);
            });
        });
    });
});

SPEC_END
