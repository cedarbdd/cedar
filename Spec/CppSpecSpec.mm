#define HC_SHORTHAND
#if TARGET_OS_IPHONE
#import "CDRSpec.h"
#import "OCMock.h"
#import "OCHamcrest.h"
#else
#import <Cedar/CDRSpec.h>
#import <OCMock/OCMock.h>
#import <OCHamcrest/OCHamcrest.h>
#endif

@interface CppSpecSpec : CDRSpec
@end

@implementation CppSpecSpec
- (void)declareBehaviors
{
    id desc = ^{
        __block int expectedValue;
        
        beforeEach(^{
            expectedValue = 1;
        });
        
        it(@"should run", ^{
            assertThatInt(1, equalToInt(expectedValue));
        });
    };
    
    describe(@"CppSpec", ^{
        describe(@"Expectations", ^{
            describe(@"with built-in types", desc);
        });
    });
}
@end
