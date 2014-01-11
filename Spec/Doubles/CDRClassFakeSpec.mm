#import <Cedar/SpecHelper.h>
#import "SimpleIncrementer.h"
#import "ObjectWithForwardingTarget.h"
#import "ObjectWithWeakDelegate.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CDRClassFakeSpec)

sharedExamplesFor(@"a Cedar class fake", ^(NSDictionary *sharedContext) {
    __block SimpleIncrementer<CedarDouble> *fake;
    SEL wibble_wobbleSelector = NSSelectorFromString(@"wibble_wobble");

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
                [fake respondsToSelector:wibble_wobbleSelector] should_not be_truthy;
            });
        });
    });

    describe(@"-description", ^{
        it(@"should return the description of the faked class", ^{
            fake.description should contain(@"Fake implementation of SimpleIncrementer class");
        });
    });

    describe(@"-conformsToProtocol:", ^{
        it(@"should be true for protocols adopted by the faked class", ^{
            [fake conformsToProtocol:@protocol(SimpleIncrementer)] should be_truthy;
        });

        it(@"should be true for protocols inherited by protocols adopted by the faked class", ^{
            [fake conformsToProtocol:@protocol(InheritedProtocol)] should be_truthy;
        });

        it(@"should not be true for other protocols", ^{
            [fake conformsToProtocol:@protocol(CedarDouble)] should_not be_truthy;
            [fake conformsToProtocol:@protocol(NSCoding)] should_not be_truthy;
        });
    });

    describe(@"-isKindOfClass:", ^{
        it(@"should be true for the faked class", ^{
            [fake isKindOfClass:[SimpleIncrementer class]] should be_truthy;
        });

        it(@"should be true for superclasses of the faked class", ^{
            [fake isKindOfClass:[IncrementerBase class]] should be_truthy;
        });

        it(@"should be false for other classes", ^{
            [fake isKindOfClass:[CDRClassFake class]] should_not be_truthy;
            [fake isKindOfClass:[NSString class]] should_not be_truthy;
        });
    });

    it(@"-class should return the faked class", ^{
        [fake class] should equal([SimpleIncrementer class]);
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

    describe(@"faking a class with interface categories", ^{
        __block ObjectWithForwardingTarget *fake;

        beforeEach(^{
            fake = fake_for([ObjectWithForwardingTarget class]);
        });

        it(@"should allow stubbing of methods declared in a category without a corresponding category implementation", ^{
            fake stub_method("count").and_return((NSUInteger)42);

            fake.count should equal(42);
        });

        it(@"should raise a descriptive exception when a method signature couldn't be resolved", ^{
            ^{
                fake stub_method("unforwardedUnimplementedMethod");
            } should raise_exception.with_reason([NSString stringWithFormat:@"Attempting to stub method <unforwardedUnimplementedMethod>, which double <%@> does not respond to", [fake description]]);
        });
    });

    describe(@"using Key Value Coding to set values", ^{
        __block ObjectWithWeakDelegate *fake;

        describe(@"a nice fake", ^{
            beforeEach(^{
                fake = nice_fake_for([ObjectWithWeakDelegate class]);
            });

            it(@"should not blow up, silently failing when setValue:forKey: is invoked", ^{
                [fake setValue:nice_fake_for(@protocol(ExampleDelegate)) forKey:@"delegate"];

                fake.delegate should be_nil;
            });
        });

        describe(@"a strict fake", ^{
            __block id delegate;
            beforeEach(^{
                delegate = nice_fake_for(@protocol(ExampleDelegate));
                fake = fake_for([ObjectWithWeakDelegate class]);
            });

            context(@"when not stubbed first", ^{
                it(@"should blow up when setValue:forKey: is invoked", ^{
                    ^{
                        [fake setValue:delegate forKey:@"delegate"];
                    } should raise_exception.with_name(NSInternalInconsistencyException).with_reason([NSString stringWithFormat:@"Attempting to set value <%@> for key <%@>, which must be stubbed first", delegate, @"delegate"]);
                });
            });

            context(@"when stubbed", ^{
                it(@"should happily receive -setValue:forKey:", ^{
                    fake stub_method(@selector(setValue:forKey:));

                    [fake setValue:delegate forKey:@"delegate"];

                    fake should have_received(@selector(setValue:forKey:)).with(delegate).and_with(@"delegate");
                });

                it(@"should happily receive -setValue:forKeyPath:", ^{
                    fake stub_method(@selector(setValue:forKeyPath:));

                    [fake setValue:delegate forKeyPath:@"delegate"];

                    fake should have_received(@selector(setValue:forKeyPath:)).with(delegate).and_with(@"delegate");
                });
            });
        });
    });
    
    describe(@"trying to create a fake for multiple classes", ^{
        it(@"should fail with a reasonable message", ^{
            ^{ nice_fake_for([SimpleIncrementer class], [NSValue class]); } should raise_exception.with_reason(@"Can't create a fake for multiple classes.");
        });
    });
});

SPEC_END
