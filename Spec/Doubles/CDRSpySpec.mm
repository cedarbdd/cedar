#import <Cedar/SpecHelper.h>

extern "C" {
#import "ExpectFailureWithMessage.h"
}

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface Thing : NSObject
@property (nonatomic, assign) size_t value;
- (void)increment;
@end

@implementation Thing
@synthesize value = value_;
- (void)increment {
    ++self.value;
}
@end

SPEC_BEGIN(SpyOnSpec)

describe(@"spy_on", ^{
    __block Thing *thing;

    beforeEach(^{
        thing = [[[Thing alloc] init] autorelease];
        spy_on(thing);
    });

    it(@"should not change the functionality of the given object", ^{
        [thing increment];
        thing.value should equal(1);
    });

    it(@"should not change the methods the given object responds to", ^{
        [thing respondsToSelector:@selector(increment)] should be_truthy;
    });

    it(@"should not affect other instances of the same class", ^{
        [thing respondsToSelector:@selector(sent_messages)] should be_truthy;

        id other_thing = [[[Thing alloc] init] autorelease];
        [other_thing respondsToSelector:@selector(sent_messages)] should_not be_truthy;
    });

    it(@"should record messages sent to the object", ^{
        ((CDRSpy *)thing).sent_messages should be_empty;

        [thing increment];
        ((CDRSpy *)thing).sent_messages should_not be_empty;
    });
});

SPEC_END
