#import "Cedar.h"
#import "ExpectFailureWithMessage.h"

@protocol INonConformer
@end

@protocol IConformer
@end

@interface Conformer : NSObject <IConformer>

@end

@implementation Conformer
@end

using namespace Cedar::Matchers;

SPEC_BEGIN(ConformToSpec)

describe(@"conform_to matcher", ^{

    context(@"when called on class", ^{
        __block Class subject = Nil;

        beforeEach(^{
            subject = [Conformer class];
        });

        afterEach(^{
            subject = Nil;
        });

        describe(@"positive match", ^{
            it(@"should pass with protocol", ^{
                subject should conform_to(@protocol(IConformer));
            });

            it(@"should pass with string", ^{
                subject should conform_to("IConformer");
            });

            it(@"should fail with a sensible failure message", ^{
                const char *protocolName = "INonConformer";
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to conform to <%s> protocol", subject, protocolName], ^{
                    subject should conform_to(protocolName);
                });
            });
        });

        describe(@"negative match", ^{
            it(@"should pass with protocol", ^{
                subject should_not conform_to(@protocol(INonConformer));
            });

            it(@"should pass with string", ^{
                subject should_not conform_to("INonConformer");
            });

            it(@"should fail with a sensible failure message", ^{
                Protocol *protocol = @protocol(IConformer);
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not conform to <%@> protocol", subject, NSStringFromProtocol(protocol)], ^{
                    subject should_not conform_to(protocol);
                });
            });
        });
    });

    context(@"when called on instance", ^{
        __block Conformer *subject = nil;

        beforeEach(^{
            subject = [[[Conformer alloc] init] autorelease];
        });

        afterEach(^{
            subject = nil;
        });

        describe(@"positive match", ^{
            it(@"should pass with protocol", ^{
                subject should conform_to(@protocol(IConformer));
            });

            it(@"should pass with string", ^{
                subject should conform_to("IConformer");
            });

            it(@"should fail with a sensible failure message", ^{
                Protocol *protocol = @protocol(INonConformer);
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to conform to <%@> protocol", subject, NSStringFromProtocol(protocol)], ^{
                    subject should conform_to(protocol);
                });
            });
        });

        describe(@"negative match", ^{
            it(@"should pass with protocol", ^{
                subject should_not conform_to(@protocol(INonConformer));
            });

            it(@"should pass with string", ^{
                subject should_not conform_to("INonConformer");
            });

            it(@"should fail with a sensible failure message", ^{
                Protocol *protocol = @protocol(IConformer);
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not conform to <%@> protocol", subject, NSStringFromProtocol(protocol)], ^{
                    subject should_not conform_to(protocol);
                });
            });
        });
    });
});

SPEC_END
