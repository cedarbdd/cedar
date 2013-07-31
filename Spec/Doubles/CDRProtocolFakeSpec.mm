#import <Cedar/SpecHelper.h>
#import <objc/runtime.h>
#import "SimpleIncrementer.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CDRProtocolFakeSpec)

sharedExamplesFor(@"a Cedar protocol fake", ^(NSDictionary *sharedContext) {
    __block id<CedarDouble, SimpleIncrementer> fake;

    beforeEach(^{
        fake = [sharedContext objectForKey:@"double"];
    });

    describe(@"-respondsToSelector:", ^{
        context(@"when an instance method is required", ^{
            it(@"should return true", ^{
                [fake respondsToSelector:@selector(value)] should be_truthy;
            });
        });

        context(@"when an instance method is not defined", ^{
            it(@"should return false", ^{
                [fake respondsToSelector:@selector(wibble_wobble)] should_not be_truthy;
            });
        });
    });

    describe(@"-description", ^{
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
        itShouldBehaveLike(@"a Cedar double when used with ARC");
        itShouldBehaveLike(@"a Cedar protocol fake");
        itShouldBehaveLike(@"a Cedar ordinary fake");

        context(@"when calling a method which has not been stubbed", ^{
            it(@"should raise an exception", ^{
                ^{ [fake value]; } should raise_exception;
            });
        });

        context(@"when calling an optional protocol method", ^{
            it(@"should raise an exception", ^{
                ^{ [fake whatIfIIncrementedBy:2]; } should raise_exception;
            });
        });

        describe(@"handling optional protocol methods", ^{
            it(@"should not respond to unstubbed selectors", ^{
                [fake respondsToSelector:@selector(whatIfIIncrementedBy:)] should equal(NO);
            });

            it(@"should raise exception when unstubbed optional method invoked", ^{
                ^{ [fake whatIfIIncrementedBy:1]; } should raise_exception;
            });

            context(@"when the method is stubbed", ^{
                beforeEach(^{
                    fake stub_method(@selector(whatIfIIncrementedBy:)).and_return((size_t)42);
                });

                it(@"should return respond to its selector", ^{
                    [fake respondsToSelector:@selector(whatIfIIncrementedBy:)] should equal(YES);
                });
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
        itShouldBehaveLike(@"a Cedar double when used with ARC");
        itShouldBehaveLike(@"a Cedar protocol fake");
        itShouldBehaveLike(@"a Cedar nice fake");

        context(@"when calling a method which has not been stubbed", ^{
            it(@"should allow method invocation without stubbing", ^{
                [nice_fake incrementBy:3];
            });

            it(@"should default to returning a 0", ^{
                expect(nice_fake.aVeryLargeNumber).to(equal(0));
            });

            it(@"should respond to optional methods", ^{
                [nice_fake respondsToSelector:@selector(whatIfIIncrementedBy:)] should be_truthy;
            });

            it(@"should record invocations of optional methods", ^{
                [nice_fake whatIfIIncrementedBy:7];
                nice_fake should have_received(@selector(whatIfIIncrementedBy:)).with(7);
            });
        });
    });
});

SPEC_END
