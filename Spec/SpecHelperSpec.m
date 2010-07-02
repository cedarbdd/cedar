#define HC_SHORTHAND
#if TARGET_OS_IPHONE
// Normally you would include this file out of the framework.  However, we're
// testing the framework here, so including the file from the framework will
// conflict with the compiler attempting to include the file from the project.
#import "SpecHelper.h"
#import "OCMock.h"
#import "OCHamcrest.h"
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

- (void)afterEach {
    //NSLog(@"=====================> AFTER EACH");
}
@end

SPEC_BEGIN(SpecHelperSpec)

describe(@"SpecHelper", ^{
    describe(@"specs", ^{
        it(@"should have an instance of SpecHelper", ^{
            assertThat([SpecHelper specHelper], notNilValue());
        });
    });

    describe(@"global beforeEach", ^{
        it(@"should run before all specs", ^{
            assertThatInt(globalValue__, equalToInt(1));
        });
    });

    describe(@"global afterEach", ^{
        it(@"should run after all specs", ^{
            // See above, and check console output.
        });
    });
});


SPEC_END
