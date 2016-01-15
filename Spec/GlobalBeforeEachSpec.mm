#import "Cedar.h"

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
