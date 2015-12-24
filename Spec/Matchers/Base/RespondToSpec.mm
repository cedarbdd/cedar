#import "Cedar.h"
#import "ExpectFailureWithMessage.h"

@interface TestResponder : NSObject
+ (void)classMethod;
- (void)instanceMethod;
@end

@implementation TestResponder
+ (void)classMethod {}
- (void)instanceMethod {}
@end

using namespace Cedar::Matchers;

SPEC_BEGIN(RespondToSpec)

describe(@"respond_to matcher", ^{

    context(@"when called on class", ^{
        __block Class subject = Nil;

        beforeEach(^{
            subject = [TestResponder class];
        });

        afterEach(^{
            subject = Nil;
        });

        describe(@"positive match", ^{
            it(@"should pass with selector", ^{
                subject should respond_to(@selector(classMethod));
            });

            it(@"should pass with string", ^{
                subject should respond_to("classMethod");
            });

            it(@"should fail with a sensible failure message", ^{
                const char *methodName = "nonExistentClassMethod";
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to respond to <%s> selector", subject, methodName], ^{
                    subject should respond_to(methodName);
                });
            });
        });

        describe(@"negative match", ^{
            it(@"should pass with selector", ^{
                subject should_not respond_to(NSSelectorFromString(@"nonExistentClassMethod"));
            });

            it(@"should pass with string", ^{
                subject should_not respond_to("nonExistentClassMethod");
            });

            it(@"should fail with a sensible failure message", ^{
                const char *methodName = "classMethod";
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not respond to <%s> selector", subject, methodName], ^{
                    subject should_not respond_to(methodName);
                });
            });
        });
    });

    context(@"when called on instance", ^{
        __block TestResponder *subject = nil;

        beforeEach(^{
            subject = [[TestResponder new] autorelease];
        });

        afterEach(^{
            subject = nil;
        });

        describe(@"positive match", ^{
            it(@"should pass with selector", ^{
                subject should respond_to(@selector(instanceMethod));
            });

            it(@"should pass with string", ^{
                subject should respond_to("instanceMethod");
            });

            it(@"should fail with a sensible failure message", ^{
                const char *methodName = "nonExistentInstanceMethod";
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to respond to <%s> selector", subject, methodName], ^{
                    subject should respond_to(methodName);
                });
            });
        });

        describe(@"negative match", ^{
            it(@"should pass with selector", ^{
                subject should_not respond_to(NSSelectorFromString(@"nonExistentInstanceMethod"));
            });

            it(@"should pass with string", ^{
                subject should_not respond_to("nonExistentInstanceMethod");
            });

            it(@"should fail with a sensible failure message", ^{
                const char *methodName = "instanceMethod";
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not respond to <%s> selector", subject, methodName], ^{
                    subject should_not respond_to(methodName);
                });
            });
        });
    });
});

SPEC_END
