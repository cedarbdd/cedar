#import <Cedar/SpecHelper.h>
#import "SimpleIncrementer.h"

extern "C" {
#import "ExpectFailureWithMessage.h"
}

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SpyOnSpec)

describe(@"spy_on", ^{
    __block SimpleIncrementer *incrementer;

    beforeEach(^{
        incrementer = [[[SimpleIncrementer alloc] init] autorelease];
        spy_on(incrementer);
    });

    it(@"should not change the functionality of the given object", ^{
        [incrementer increment];
        incrementer.value should equal(1);
    });

    it(@"should not change the methods the given object responds to", ^{
        [incrementer respondsToSelector:@selector(increment)] should be_truthy;
    });

    it(@"should not affect other instances of the same class", ^{
        [incrementer respondsToSelector:@selector(sent_messages)] should be_truthy;

        id other_incrementer = [[[SimpleIncrementer alloc] init] autorelease];
        [other_incrementer respondsToSelector:@selector(sent_messages)] should_not be_truthy;
    });

    it(@"should record messages sent to the object", ^{
        ((CDRSpy *)incrementer).sent_messages should be_empty;

        [incrementer increment];
        ((CDRSpy *)incrementer).sent_messages should_not be_empty;
    });

    it(@"should return the description of the spied-upon object", ^{
        incrementer.description should contain(@"SimpleIncrementer");
    });

    it(@"should only create one spy for a given object" , ^{
        ((CDRSpy *)incrementer).sent_messages should be_empty;
        spy_on(incrementer);
        [incrementer increment];
        ((CDRSpy *)incrementer).sent_messages should_not be_empty;
    });

});

SPEC_END
