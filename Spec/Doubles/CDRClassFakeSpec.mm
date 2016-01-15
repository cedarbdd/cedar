#import "Cedar.h"
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

            [[CDRSpecHelper specHelper].sharedExampleContext setObject:fake forKey:@"double"];
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

            [[CDRSpecHelper specHelper].sharedExampleContext setObject:niceFake forKey:@"double"];
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

    describe(@"using Key Value Coding", ^{
        __block ObjectWithWeakDelegate *fake;
        __block id delegate;

        describe(@"to set values", ^{
            beforeEach(^{
                delegate = nice_fake_for(@protocol(ExampleDelegate));
            });

            describe(@"a nice fake", ^{
                beforeEach(^{
                    fake = nice_fake_for([ObjectWithWeakDelegate class]);
                });

                sharedExamplesFor(@"silently handling KVC setters", ^(NSDictionary *sharedContext) {
                    it(@"should not blow up, silently failing when setValue:forKey: is invoked", ^{
                        [fake setValue:nice_fake_for(@protocol(ExampleDelegate)) forKey:sharedContext[@"key"]];
                        fake.delegate should be_nil;
                    });

                    it(@"should not blow up, silently failing when setValue:forKeyPath: is invoked", ^{
                        [fake setValue:nice_fake_for(@protocol(ExampleDelegate)) forKeyPath:sharedContext[@"key"]];
                        fake.delegate should be_nil;
                    });

                    it(@"should record that it has received setValue:forKey:", ^{
                        [fake setValue:delegate forKey:sharedContext[@"key"]];
                        fake should have_received(@selector(setValue:forKey:)).with(delegate, sharedContext[@"key"]);
                    });

                    it(@"should record that it has received setValue:forKeyPath:", ^{
                        [fake setValue:delegate forKeyPath:sharedContext[@"key"]];
                        fake should have_received(@selector(setValue:forKeyPath:)).with(delegate, sharedContext[@"key"]);
                    });
                });
                
                describe(@"with a key that is KVC-compliant", ^{
                    itShouldBehaveLike(@"silently handling KVC setters", ^(NSMutableDictionary *context) {
                        context[@"key"] = @"delegate";
                    });
                });

                describe(@"with a key that is not KVC-compliant", ^{
                    itShouldBehaveLike(@"silently handling KVC setters", ^(NSMutableDictionary *context) {
                        context[@"key"] = @"bogus";
                    });
                });
            });

            describe(@"a strict fake", ^{
                beforeEach(^{
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

        describe(@"to get values", ^{
            describe(@"a nice fake", ^{
                beforeEach(^{
                    fake = nice_fake_for([ObjectWithWeakDelegate class]);
                });

                sharedExamplesFor(@"silently handling KVC getters", ^(NSDictionary *sharedContext) {
                    it(@"should not blow up, returning nil when valueForKey: is invoked", ^{
                        [fake valueForKey:sharedContext[@"key"]] should be_nil;
                    });

                    it(@"should not blow up, returning nil when valueForKeyPath: is invoked", ^{
                        [fake valueForKeyPath:sharedContext[@"key"]] should be_nil;
                    });

                    it(@"should record that it has received valueForKey:", ^{
                        [fake valueForKey:sharedContext[@"key"]];
                        fake should have_received(@selector(valueForKey:)).with(sharedContext[@"key"]);
                    });

                    it(@"should record that it has received valueForKeyPath:", ^{
                        [fake valueForKeyPath:sharedContext[@"key"]];
                        fake should have_received(@selector(valueForKeyPath:)).with(sharedContext[@"key"]);
                    });
                });

                describe(@"with a key that is KVC-compliant", ^{
                    itShouldBehaveLike(@"silently handling KVC getters", ^(NSMutableDictionary *context) {
                        context[@"key"] = @"delegate";
                    });
                });

                describe(@"with a key that is not KVC-compliant", ^{
                    itShouldBehaveLike(@"silently handling KVC getters", ^(NSMutableDictionary *context) {
                        context[@"key"] = @"bogus";
                    });
                });
            });

            describe(@"a strict fake", ^{
                beforeEach(^{
                    fake = fake_for([ObjectWithWeakDelegate class]);
                });

                context(@"when not stubbed first", ^{
                    it(@"should blow up when valueForKey: is invoked", ^{
                        ^{
                            [fake valueForKey:@"delegate"];
                        } should raise_exception.with_name(NSInternalInconsistencyException).with_reason([NSString stringWithFormat:@"Attempting to get value for key <%@>, which must be stubbed first", @"delegate"]);
                    });
                });

                context(@"when stubbed with no return value", ^{
                    it(@"should happily receive -valueForKey: and return nil", ^{
                        fake stub_method(@selector(valueForKey:));

                        [fake valueForKey:@"delegate"];

                        fake should have_received(@selector(valueForKey:)).with(@"delegate");
                    });

                    it(@"should happily receive -valueForKeyPath:", ^{
                        fake stub_method(@selector(valueForKeyPath:));

                        [fake valueForKeyPath:@"delegate"];

                        fake should have_received(@selector(valueForKeyPath:)).with(@"delegate");
                    });
                });

                context(@"when stubbed with a return value", ^{
                    beforeEach(^{
                        delegate = nice_fake_for(@protocol(ExampleDelegate));
                    });

                    it(@"should receive -valueForKey: and return the stubbed value", ^{
                        fake stub_method(@selector(valueForKey:)).with(@"delegate").and_return(delegate);
                        [fake valueForKey:@"delegate"] should be_same_instance_as(delegate);
                    });

                    it(@"should receive -valueForKeyPath: and return the stubbed value", ^{
                        fake stub_method(@selector(valueForKeyPath:)).with(@"delegate").and_return(delegate);
                        [fake valueForKeyPath:@"delegate"] should be_same_instance_as(delegate);
                    });
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
