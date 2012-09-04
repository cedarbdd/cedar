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

        [[SpecHelper specHelper].sharedExampleContext setObject:incrementer forKey:@"double"];
    });

    itShouldBehaveLike(@"a Cedar double");

    it(@"should not change the functionality of the given object", ^{
        [incrementer increment];
        incrementer.value should equal(1);
    });

    it(@"should not change the methods the given object responds to", ^{
        [incrementer respondsToSelector:@selector(increment)] should be_truthy;
        [incrementer respondsToSelector:@selector(wibble)] should_not be_truthy;
    });

    it(@"should not affect other instances of the same class", ^{
        [[incrementer class] conformsToProtocol:@protocol(CedarDouble)] should be_truthy;

        id other_incrementer = [[[SimpleIncrementer alloc] init] autorelease];
        [[other_incrementer class] conformsToProtocol:@protocol(CedarDouble)] should_not be_truthy;
    });

    it(@"should record messages sent to the object", ^{
        incrementer should_not have_received("increment");
        [incrementer increment];
        incrementer should have_received("increment");
    });

    xit(@"should record messages sent by the object to itself", ^{
        [incrementer incrementBy:7];
        incrementer should have_received("setValue:");
    });

    it(@"should return the description of the spied-upon object", ^{
        incrementer.description should contain(@"SimpleIncrementer");
    });

    it(@"should only spy on a given object once" , ^{
        [incrementer increment];
        spy_on(incrementer);
        incrementer should have_received("increment");
    });
});

SPEC_END
