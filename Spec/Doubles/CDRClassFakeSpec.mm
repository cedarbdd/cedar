#import <Cedar/SpecHelper.h>
#import "SimpleIncrementer.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CDRClassFakeSpec)

sharedExamplesFor(@"a Cedar class fake", ^(NSDictionary *sharedContext) {
    __block id<CedarDouble, SimpleIncrementer> fake;

    beforeEach(^{
        fake = [sharedContext objectForKey:@"double"];
    });

    describe(@"-respondsToSelector:", ^{
        context(@"when an instance method is defined", ^{
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
        it(@"should return the description of the faked class", ^{
            fake.description should contain(@"Fake implementation of SimpleIncrementer class");
        });
    });
});

describe(@"CDRClassFake", ^{
    describe(@"fake_for(Class)", ^{
        __block SimpleIncrementer<CedarDouble> *fake;

        beforeEach(^{
            fake = fake_for([SimpleIncrementer class]);

            [[SpecHelper specHelper].sharedExampleContext setObject:fake forKey:@"double"];
        });

        itShouldBehaveLike(@"a Cedar double");
        itShouldBehaveLike(@"a Cedar double when used with ARC");
        itShouldBehaveLike(@"a Cedar class fake");
        itShouldBehaveLike(@"a Cedar ordinary fake");

        context(@"when calling a method which has not been stubbed", ^{
            it(@"should raise an exception", ^{
                ^{ [fake value]; } should raise_exception;
            });
        });
    });

    describe(@"nice_fake_for(Class)", ^{
        __block SimpleIncrementer<CedarDouble> *niceFake;

        beforeEach(^{
            niceFake = nice_fake_for([SimpleIncrementer class]);

            [[SpecHelper specHelper].sharedExampleContext setObject:niceFake forKey:@"double"];
        });

        itShouldBehaveLike(@"a Cedar double");
        itShouldBehaveLike(@"a Cedar double when used with ARC");
        itShouldBehaveLike(@"a Cedar class fake");
        itShouldBehaveLike(@"a Cedar nice fake");

        context(@"when calling a method which has not been stubbed", ^{
            it(@"should allow method invocation without stubbing", ^{
                [niceFake incrementBy:3];
            });

            it(@"should default to returning a 0", ^{
                expect([niceFake aVeryLargeNumber]).to(equal(0));
            });
        });
    });
});


SPEC_END
