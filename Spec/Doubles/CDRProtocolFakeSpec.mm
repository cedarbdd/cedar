#import <Cedar/SpecHelper.h>
#import "SimpleIncrementer.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CDRProtocolFakeSpec)

sharedExamplesFor(@"a Cedar protocol fake", ^(NSDictionary *sharedContext) {
    __block id<CedarDouble, SimpleIncrementer> fake;

    beforeEach(^{
        fake = [sharedContext objectForKey:@"double"];
    });

    describe(@"#respondsToSelector:", ^{
        context(@"when an instance method is required", ^{
            it(@"should return true", ^{
                [fake respondsToSelector:@selector(value)] should be_truthy;
            });
        });

        context(@"when an instance method is optional", ^{
            it(@"should return true", ^{
                [fake respondsToSelector:@selector(whatIfIIncrementedBy:)] should be_truthy;
            });
        });

        context(@"when an instance method is not defined", ^{
            it(@"should return false", ^{
                [fake respondsToSelector:@selector(wibble_wobble)] should_not be_truthy;
            });
        });
    });

    describe(@"#description", ^{
        it(@"should return the description of the faked protocol", ^{
            fake.description should contain([NSString stringWithFormat:@"Fake implementation of %s protocol", protocol_getName(@protocol(SimpleIncrementer))]);
        });
    });
});

describe(@"fake (protocol)", ^{
    describe(@"fake_for(Protocol)", ^{
        __block SimpleIncrementer<CedarDouble> *fake;

        beforeEach(^{
            fake = fake_for(@protocol(SimpleIncrementer));

            [[SpecHelper specHelper].sharedExampleContext setObject:fake forKey:@"double"];
        });

        itShouldBehaveLike(@"a Cedar double");
        itShouldBehaveLike(@"a Cedar protocol fake");

        context(@"when calling a method which has not been stubbed", ^{
            it(@"should raise an exception", ^{
                ^{ [fake value]; } should raise_exception;
            });
        });

    });

    describe(@"nice_fake_for(Protocol)", ^{
        __block SimpleIncrementer<CedarDouble> *nice_fake;

        beforeEach(^{
            nice_fake = nice_fake_for(@protocol(SimpleIncrementer));

            [[SpecHelper specHelper].sharedExampleContext setObject:nice_fake forKey:@"double"];
        });

        itShouldBehaveLike(@"a Cedar double");
        itShouldBehaveLike(@"a Cedar protocol fake");

        context(@"when calling a method which has not been stubbed", ^{
            it(@"should allow method invocation without stubbing", ^{
                [nice_fake incrementBy:3];
            });

            it(@"should default to returning a 0", ^{
                expect(nice_fake.aVeryLargeNumber).to(equal(0));
            });
        });
    });
});

SPEC_END
