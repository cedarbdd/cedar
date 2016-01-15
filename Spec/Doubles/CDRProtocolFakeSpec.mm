#import "Cedar.h"
#import <objc/runtime.h>
#import "SimpleIncrementer.h"
#import "SimpleMultiplier.h"

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

describe(@"fake (protocol)", ^{
    describe(@"fake_for(Protocol)", ^{
        __block id<SimpleIncrementer, CedarDouble> fake;

        beforeEach(^{
            fake = fake_for(@protocol(SimpleIncrementer));

            [[CDRSpecHelper specHelper].sharedExampleContext setObject:fake forKey:@"double"];
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

        describe(@"-description", ^{
            it(@"should return the description of the faked protocol", ^{
                fake.description should contain(@"Fake implementation of SimpleIncrementer protocol(s)");
            });
        });

        describe(@"handling optional protocol methods", ^{
            it(@"should not respond to unstubbed selectors", ^{
                fake should_not respond_to(@selector(whatIfIIncrementedBy:));
            });

            it(@"should raise exception when unstubbed optional method invoked", ^{
                ^{ [fake whatIfIIncrementedBy:1]; } should raise_exception;
            });

            context(@"when the method is stubbed", ^{
                beforeEach(^{
                    fake stub_method(@selector(whatIfIIncrementedBy:)).and_return((size_t)42);
                });

                it(@"should respond to its selector", ^{
                    fake should respond_to(@selector(whatIfIIncrementedBy:));
                });
            });
        });
    });

    describe(@"nice_fake_for(Protocol)", ^{
        __block id<SimpleIncrementer, CedarDouble> nice_fake;

        beforeEach(^{
            nice_fake = nice_fake_for(@protocol(SimpleIncrementer));

            [[CDRSpecHelper specHelper].sharedExampleContext setObject:nice_fake forKey:@"double"];
        });

        itShouldBehaveLike(@"a Cedar double");
        itShouldBehaveLike(@"a Cedar double when used with ARC");
        itShouldBehaveLike(@"a Cedar protocol fake");
        itShouldBehaveLike(@"a Cedar nice fake");

        describe(@"-description", ^{
            it(@"should return the description of the faked protocol", ^{
                nice_fake.description should contain(@"Fake implementation of SimpleIncrementer protocol(s)");
            });
        });

        context(@"when calling a method which has not been stubbed", ^{
            it(@"should allow method invocation without stubbing", ^{
                [nice_fake incrementBy:3];
            });

            it(@"should default to returning a 0", ^{
                expect(nice_fake.aVeryLargeNumber).to(equal(0));
            });

            it(@"should respond to optional methods", ^{
                nice_fake should respond_to(@selector(whatIfIIncrementedBy:));
            });

            it(@"should record invocations of optional methods", ^{
                [nice_fake whatIfIIncrementedBy:7];
                nice_fake should have_received(@selector(whatIfIIncrementedBy:)).with(7);
            });
        });

        describe(@"rejecting an optional method", ^{
            beforeEach(^{
                nice_fake reject_method(@selector(whatIfIIncrementedBy:));
            });

            it(@"should not respond to the method's selector", ^{
                nice_fake should_not respond_to(@selector(whatIfIIncrementedBy:));
            });

            it(@"should raise a helpful exception when the method is called", ^{
                ^{ [nice_fake whatIfIIncrementedBy:1]; } should raise_exception.with_reason(@"Received message with explicitly rejected selector <whatIfIIncrementedBy:>");
            });
        });
    });

    describe(@"fake_for(Protocol, Protocol, ...)", ^{
        __block id<SimpleIncrementer, SimpleMultiplier, CedarDouble> fake;

        beforeEach(^{
            fake = fake_for(@protocol(SimpleIncrementer), @protocol(SimpleMultiplier));

            [[CDRSpecHelper specHelper].sharedExampleContext setObject:fake forKey:@"double"];
        });

        itShouldBehaveLike(@"a Cedar double");
        itShouldBehaveLike(@"a Cedar double when used with ARC");
        itShouldBehaveLike(@"a Cedar protocol fake");
        itShouldBehaveLike(@"a Cedar ordinary fake");

        it(@"should respond to methods from both protocols", ^{
            fake should respond_to(@selector(incrementBy:));
            fake should respond_to(@selector(multiplyBy:));
        });

        it(@"should conform to both protocols", ^{
            [fake conformsToProtocol:@protocol(SimpleIncrementer)] should equal(YES);
            [fake conformsToProtocol:@protocol(SimpleMultiplier)] should equal(YES);
        });

        describe(@"-description", ^{
            it(@"should return the description of the faked protocols", ^{
                fake.description should contain(@"Fake implementation of SimpleIncrementer, SimpleMultiplier protocol(s)");
            });
        });

        context(@"when calling methods that have been stubbed", ^{
            beforeEach(^{
                fake stub_method(@selector(incrementBy:));
                fake stub_method(@selector(multiplyBy:));
            });

            it(@"should allow invocation of methods from both protocols", ^{
                [fake incrementBy:3];
                [fake multiplyBy:5];
            });

            it(@"should record invocations of methods from both protocols", ^{
                [fake incrementBy:7];
                fake should have_received(@selector(incrementBy:)).with(7);

                [fake multiplyBy:8];
                fake should have_received(@selector(multiplyBy:)).with(8);
            });
        });
    });

    describe(@"nice_fake_for(Protocol, Protocol, ...)", ^{
        __block id<SimpleIncrementer, SimpleMultiplier, CedarDouble> nice_fake;

        beforeEach(^{
            nice_fake = nice_fake_for(@protocol(SimpleIncrementer), @protocol(SimpleMultiplier));

            [[CDRSpecHelper specHelper].sharedExampleContext setObject:nice_fake forKey:@"double"];
        });

        itShouldBehaveLike(@"a Cedar double");
        itShouldBehaveLike(@"a Cedar double when used with ARC");
        itShouldBehaveLike(@"a Cedar protocol fake");
        itShouldBehaveLike(@"a Cedar nice fake");

        it(@"should respond to methods from both protocols", ^{
            nice_fake should respond_to(@selector(incrementBy:));
            nice_fake should respond_to(@selector(multiplyBy:));
        });

        it(@"should allow method invocation from both protocols without stubbing", ^{
            [nice_fake incrementBy:3];
            [nice_fake multiplyBy:5];
        });

        it(@"should conform to both protocols", ^{
            [nice_fake conformsToProtocol:@protocol(SimpleIncrementer)] should equal(YES);
            [nice_fake conformsToProtocol:@protocol(SimpleMultiplier)] should equal(YES);
        });

        it(@"should record invocations of methods from both protocols", ^{
            [nice_fake incrementBy:7];
            nice_fake should have_received(@selector(incrementBy:)).with(7);

            [nice_fake multiplyBy:8];
            nice_fake should have_received(@selector(multiplyBy:)).with(8);
        });

        describe(@"-description", ^{
            it(@"should return the description of the faked protocols", ^{
                nice_fake.description should contain(@"Fake implementation of SimpleIncrementer, SimpleMultiplier protocol(s)");
            });
        });
    });
});

SPEC_END
