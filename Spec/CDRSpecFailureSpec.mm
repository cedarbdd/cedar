#if TARGET_OS_IPHONE
// Normally you would include this file out of the framework.  However, we're
// testing the framework here, so including the file from the framework will
// conflict with the compiler attempting to include the file from the project.
#import "SpecHelper.h"
#else
#import <Cedar/SpecHelper.h>
#endif

#import "CDRSpecFailure.h"

using namespace Cedar::Matchers;
static NSDictionary *reasonsToFileNames;

SPEC_BEGIN(CDRSpecFailureSpec)

reasonsToFileNames = [NSDictionary dictionaryWithObjectsAndKeys:
                      @"File.h",                                @"File.h:123 reason",
                      @"C:/Directory/File.h",                   @"C:/Directory/File.h:123 reason",
                      @"Some Directory/File.m",                 @"Some Directory/File.m:123 reason",
                      @"Some\\ Directory/File.m",               @"Some\\ Directory/File.m:123 reason",
                      @"Some Directory/File.m",                 @"Some Directory/File.m(123): reason",
                      @"Some Directory (something)/File.m",     @"Some Directory (something)/File.m(123) reason",
                      nil];

describe(@"CDRSpecFailure", ^{
    __block CDRSpecFailure *failure;

    context(@"for a failure instantiated only with a reason", ^{
        context(@"when file name and line number are not specified inside reason", ^{
            beforeEach(^{
                failure = [CDRSpecFailure specFailureWithReason:@"reason"];
            });

            it(@"should return failure's reason", ^{
                expect([failure reason]).to(equal(@"reason"));
            });

            it(@"should return nil for file name", ^{
                expect([failure fileName]).to(be_nil());
            });

            it(@"should return 0 for line number", ^{
                expect([failure lineNumber]).to(equal(0));
            });
        });

        context(@"when file name and line number are specified inside reason", ^{
            for (NSString *reason in reasonsToFileNames) {
                NSString *fileName = [reasonsToFileNames objectForKey:reason];

                it([NSString stringWithFormat:@"should return reason 'reason' parsed from '%@'", reason], ^{
                    CDRSpecFailure *failure = [CDRSpecFailure specFailureWithReason:reason];
                    expect([failure reason]).to(equal(@"reason"));
                });

                it([NSString stringWithFormat:@"should return file name '%@' parsed from '%@'", fileName, reason], ^{
                    CDRSpecFailure *failure = [CDRSpecFailure specFailureWithReason:reason];
                    expect([failure fileName]).to(equal(fileName));
                });

                it([NSString stringWithFormat:@"should return line number '123' parsed from '%@'", reason], ^{
                    CDRSpecFailure *failure = [CDRSpecFailure specFailureWithReason:reason];
                    expect([failure lineNumber]).to(equal(123));
                });
            }
        });
    });

    context(@"for a failure instantiated with reason, file name and line number", ^{
        beforeEach(^{
            failure = [CDRSpecFailure specFailureWithReason:@"reason" fileName:@"File.m" lineNumber:123];
        });

        it(@"should return failure's reason", ^{
            expect([failure reason]).to(equal(@"reason"));
        });

        it(@"should return failure's file name", ^{
            expect([failure fileName]).to(equal(@"File.m"));
        });

        it(@"should return failure's line number", ^{
            expect([failure lineNumber]).to(equal(123));
        });
    });

    context(@"for a failure instantiated with a raised object", ^{
        context(@"when raised object is a subclass of NSException", ^{
            context(@"when file name and line number are specified in exception's userInfo", ^{
                beforeEach(^{
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"File.m", @"fileName", [NSNumber numberWithInt:123], @"lineNumber", nil];
                    NSException *exception = [NSException exceptionWithName:nil reason:@"exception reason" userInfo:userInfo];
                    failure = [CDRSpecFailure specFailureWithRaisedObject:exception];
                });

                it(@"should return exception's reason", ^{
                    expect([failure reason]).to(equal(@"exception reason"));
                });

                it(@"should return file name specified in exception's userInfo", ^{
                    expect([failure fileName]).to(equal(@"File.m"));
                });

                it(@"should return line number specified in exception's userInfo", ^{
                    expect([failure lineNumber]).to(equal(123));
                });
            });

            context(@"when file name and line number are not specified in userInfo of exception", ^{
                beforeEach(^{
                    NSException *exception = [NSException exceptionWithName:nil reason:@"exception reason" userInfo:nil];
                    failure = [CDRSpecFailure specFailureWithRaisedObject:exception];
                });

                it(@"should return raised object's reason", ^{
                    expect([failure reason]).to(equal(@"exception reason"));
                });

                it(@"should return nil for file name", ^{
                    expect([failure fileName]).to(be_nil());
                });

                it(@"should return 0 for line number", ^{
                    expect([failure lineNumber]).to(equal(0));
                });
            });
        });

        context(@"when raised object is not a subclass of NSException", ^{
            beforeEach(^{
                failure = [CDRSpecFailure specFailureWithRaisedObject:[NSNumber numberWithInt:19901113]];
            });

            it(@"should return raised object's description for reason", ^{
                expect([failure reason]).to(equal(@"19901113"));
            });

            it(@"should return nil for file name", ^{
                expect([failure fileName]).to(be_nil());
            });

            it(@"should return 0 for line number", ^{
                expect([failure lineNumber]).to(equal(0));
            });
        });
    });
});

SPEC_END
