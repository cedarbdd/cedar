#if TARGET_OS_IPHONE
#import <Cedar/SpecHelper.h>
#else
#import <Cedar/SpecHelper.h>
#endif

extern "C" {
#import "ExpectFailureWithMessage.h"
}

@interface TestResponder : NSObject
+ (void)classMethod;
- (void)instanceMethod;
@end

@implementation TestResponder
+ (void)classMethod {}
- (void)instanceMethod {}
@end

using namespace Cedar::Matchers;

SPEC_BEGIN(RespondsToSpec)

describe(@"responds_to matcher", ^{

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
                subject should responds_to(@selector(classMethod));
            });

            it(@"should pass with string", ^{
                subject should responds_to(@"classMethod");
            });

            it(@"should fail with a sensible failure message", ^{
                NSString *methodName = @"nonExistClassMethod";
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to responds to <%@> selector", subject, methodName], ^{
                    subject should responds_to(methodName);
                });
            });
        });

        describe(@"negative match", ^{
            it(@"should pass with selector", ^{
                subject should_not responds_to(@selector(nonExistClassMethod));
            });

            it(@"should pass with string", ^{
                subject should_not responds_to(@"nonExistClassMethod");
            });

            it(@"should fail with a sensible failure message", ^{
                NSString *methodName = @"classMethod";
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not responds to <%@> selector", subject, methodName], ^{
                    subject should_not responds_to(methodName);
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
                subject should responds_to(@selector(instanceMethod));
            });

            it(@"should pass with string", ^{
                subject should responds_to(@"instanceMethod");
            });

            it(@"should fail with a sensible failure message", ^{
                NSString *methodName = @"nonExistInstanceMethod";
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to responds to <%@> selector", subject, methodName], ^{
                    subject should responds_to(methodName);
                });
            });
        });

        describe(@"negative match", ^{
            it(@"should pass with selector", ^{
                subject should_not responds_to(@selector(nonExistInstanceMethod));
            });

            it(@"should pass with string", ^{
                subject should_not responds_to(@"nonExistInstanceMethod");
            });

            it(@"should fail with a sensible failure message", ^{
                NSString *methodName = @"instanceMethod";
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not responds to <%@> selector", subject, methodName], ^{
                    subject should_not responds_to(methodName);
                });
            });
        });
    });
});

SPEC_END