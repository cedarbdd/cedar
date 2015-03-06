#import <Cedar/Cedar.h>
#import "SimpleIncrementer.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SHARED_EXAMPLE_GROUPS_BEGIN(CDRProtocolFakeSharedExamples)

sharedExamplesFor(@"a Cedar protocol fake", ^(NSDictionary *sharedContext) {
    __block id<CedarDouble, SimpleIncrementer> fake;

    beforeEach(^{
        fake = [sharedContext objectForKey:@"double"];
    });

    describe(@"-respondsToSelector:", ^{
        context(@"when an instance method is required", ^{
            it(@"should return true", ^{
                fake should respond_to(@selector(value));
            });
        });

        context(@"when an instance method is not defined", ^{
            it(@"should return false", ^{
                SEL wibble_wobbleSelector = NSSelectorFromString(@"wibble_wobble");
                fake should_not respond_to(wibble_wobbleSelector);
            });
        });
    });

    describe(@"-conformsToProtocol:", ^{
        it(@"should be true for the faked protocol", ^{
            [fake conformsToProtocol:@protocol(SimpleIncrementer)] should be_truthy;
        });

        it(@"should be true for protocols inherited by the faked protocol", ^{
            [fake conformsToProtocol:@protocol(InheritedProtocol)] should be_truthy;
        });

        it(@"should not be true for other protocols", ^{
            [fake conformsToProtocol:@protocol(CedarDouble)] should_not be_truthy;
            [fake conformsToProtocol:@protocol(NSCoding)] should_not be_truthy;
        });
    });

    describe(@"stubbing methods not included in the faked protocol(s)", ^{
        it(@"should blow up", ^{
            ^{ fake stub_method(@selector(addObject:)); } should raise_exception;
        });
    });

    describe(@"rejecting methods not included in the faked protocol(s)", ^{
        it(@"should blow up", ^{
            ^{ fake reject_method(@selector(addObject:)); } should raise_exception;
        });
    });
});

SHARED_EXAMPLE_GROUPS_END
