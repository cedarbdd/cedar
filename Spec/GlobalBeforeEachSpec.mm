#if TARGET_OS_IPHONE
// Normally you would include this file out of the framework.  However, we're
// testing the framework here, so including the file from the framework will
// conflict with the compiler attempting to include the file from the project.
#import "SpecHelper.h"
#else
#import <Cedar/SpecHelper.h>
#endif

static unsigned int globalValue__ = 0;

using namespace Cedar::Matchers;

@interface SomeClass : NSObject
@end

@implementation SomeClass
+ (void)beforeEach {
    globalValue__ = 1;
}

+ (void)afterEach {
//    NSLog(@"=====================> AFTER EACH 1");
}
@end


SPEC_BEGIN(GlobalBeforeEachSpec)

describe(@"global beforeEach", ^{
    it(@"should run before all specs", ^{
        expect(globalValue__).to(equal(1));
    });
});

describe(@"global afterEach", ^{
    it(@"should run after all specs", ^{
        // Uncomment the line in the afterEach method, run, and check console output.
    });
});


SPEC_END
