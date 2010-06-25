#define HC_SHORTHAND
#if TARGET_OS_IPHONE
// Normally you would include this file out of the framework.  However, we're
// testing the framework here, so including the file from the framework will
// conflict with the compiler attempting to include the file from the project.
#import "SpecHelper.h"
#import <OCMock-iPhone/OCMock.h>
#import <OCHamcrest-iPhone/OCHamcrest.h>
#else
#import <Cedar/SpecHelper.h>
#import <OCMock/OCMock.h>
#import <OCHamcrest/OCHamcrest.h>
#endif

static unsigned int globalValue__ = 0;

@implementation SpecHelper (MySpecs)
- (void)beforeEach {
    globalValue__ = 1;
}
@end

SPEC_BEGIN(SpecHelperSpec)

describe(@"SpecHelper", ^{
    describe(@"specs", ^{
        it(@"should have an instance of SpecHelper", ^{
            assertThat(specHelper, notNilValue());
        });
    });

    describe(@"global beforeEach", ^{
        it(@"should run before all specs", ^{
            assertThatInt(globalValue__, equalToInt(1));
        });
    });
});


SPEC_END
