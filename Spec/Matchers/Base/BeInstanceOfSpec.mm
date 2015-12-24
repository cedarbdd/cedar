#import "Cedar.h"
#import "ExpectFailureWithMessage.h"

@interface FooBase : NSObject; @end
@implementation FooBase; @end

@interface FooDerived : FooBase; @end
@implementation FooDerived; @end

@interface BarNotMemberOfOwnClass : NSObject @end
@implementation BarNotMemberOfOwnClass

- (BOOL)isMemberOfClass:(Class)aClass {
    return NO;
}
- (BOOL)isKindOfClass:(Class)aClass {
    return NO;
}

@end

using namespace Cedar::Matchers;

SPEC_BEGIN(BeInstanceOfSpec)

describe(@"be_instance_of matcher", ^{
    describe(@"without decoration", ^{
        Class expectedClass = [FooBase class];

        describe(@"when the actual value is an instance of the expected class", ^{
            id actualValue = [[[FooBase alloc] init] autorelease];

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(actualValue).to(be_instance_of(expectedClass));
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@ (%@)> to not be an instance of class <%@>", actualValue, [actualValue class], expectedClass], ^{
                        expect(actualValue).to_not(be_instance_of(expectedClass));
                    });
                });
            });
        });

        describe(@"when the actual value is an instance of a subclass of the expected class", ^{
            id actualValue = [[[FooDerived alloc] init] autorelease];

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@ (%@)> to be an instance of class <%@>", actualValue, [actualValue class], expectedClass], ^{
                        expect(actualValue).to(be_instance_of(expectedClass));
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should should pass", ^{
                    expect(actualValue).to_not(be_instance_of(expectedClass));
                });
            });
        });

        describe(@"when the actual value is not an instance of the expected class, or any of its subclasses", ^{
            id actualValue = [NSString string];

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@ (%@)> to be an instance of class <%@>", actualValue, [actualValue class], expectedClass], ^{
                        expect(actualValue).to(be_instance_of(expectedClass));
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should should pass", ^{
                    expect(actualValue).to_not(be_instance_of(expectedClass));
                });
            });
        });

        describe(@"when the actual value is not an instance of the expected class but they have the same class name", ^{
            Class expectedClass = [BarNotMemberOfOwnClass class];
            id actualValue = [[[BarNotMemberOfOwnClass alloc] init] autorelease];

            describe(@"positive match", ^{
                it(@"should fail with a failure message suggesting solution to the problem", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@ (%@)> to be an instance of class <%@>. Did you accidentally add the class to your specs target also?", actualValue, [actualValue class], expectedClass], ^{
                        expect(actualValue).to(be_instance_of(expectedClass));
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should should pass", ^{
                    expect(actualValue).to_not(be_instance_of(expectedClass));
                });
            });
        });
    });

    describe(@"with the or_any_subclass decoration", ^{
        Class expectedClass = [FooBase class];

        describe(@"when the actual value is an instance of the expected class", ^{
            id actualValue = [[[FooBase alloc] init] autorelease];

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(actualValue).to(be_instance_of(expectedClass).or_any_subclass());
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@ (%@)> to not be an instance of class <%@>, or any of its subclasses", actualValue, [actualValue class], expectedClass], ^{
                        expect(actualValue).to_not(be_instance_of(expectedClass).or_any_subclass());
                    });
                });
            });
        });

        describe(@"when the actual value is an instance of a subclass of the expected class", ^{
            id actualValue = [[[FooDerived alloc] init] autorelease];

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(actualValue).to(be_instance_of(expectedClass).or_any_subclass());
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@ (%@)> to not be an instance of class <%@>, or any of its subclasses", actualValue, [actualValue class], expectedClass], ^{
                        expect(actualValue).to_not(be_instance_of(expectedClass).or_any_subclass());
                    });
                });
            });
        });

        describe(@"when the actual value is not an instance of the expected class, or any of its subclasses", ^{
            id actualValue = [NSString string];

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@ (%@)> to be an instance of class <%@>, or any of its subclasses", actualValue, [actualValue class], expectedClass], ^{
                        expect(actualValue).to(be_instance_of(expectedClass).or_any_subclass());
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should should pass", ^{
                    expect(actualValue).to_not(be_instance_of(expectedClass).or_any_subclass());
                });
            });
        });

        describe(@"when the actual value is not an instance of the expected class but they have the same class name", ^{
            Class expectedClass = [BarNotMemberOfOwnClass class];
            id actualValue = [[[BarNotMemberOfOwnClass alloc] init] autorelease];

            describe(@"positive match", ^{
                it(@"should fail with a failure message suggesting solution to the problem", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@ (%@)> to be an instance of class <%@>, or any of its subclasses. Did you accidentally add the class to your specs target also?", actualValue, [actualValue class], expectedClass], ^{
                        expect(actualValue).to(be_instance_of(expectedClass).or_any_subclass());
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should should pass", ^{
                    expect(actualValue).to_not(be_instance_of(expectedClass).or_any_subclass());
                });
            });
        });
    });
});

SPEC_END
