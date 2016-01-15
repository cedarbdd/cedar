#import "Cedar.h"
#import "CDRSymbolicator.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

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
                    NSException *exception = [NSException exceptionWithName:@"boo" reason:@"exception reason" userInfo:userInfo];
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
                    NSException *exception = [NSException exceptionWithName:@"boo" reason:@"exception reason" userInfo:nil];
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

    describe(@"-callStackSymbolicatedSymbols", ^{
        __block NSString *symbols;
        __block NSError *error;
        __block id raisedObject;

        subjectAction(^{
            CDRSpecFailure *failure =
                [CDRSpecFailure specFailureWithRaisedObject:raisedObject];
            error = nil;
            symbols = [failure callStackSymbolicatedSymbols:&error];
        });

        context(@"when raised object provides call stack return addresses", ^{
            void (^objectRaiser)(void) = ^{ [[NSException exceptionWithName:@"name" reason:@"reason" userInfo:nil] raise]; };

            beforeEach(^{
                // Raise and then catch actual exception
                // to populate its callStackReturnAddresses.
                @try {
                    objectRaiser();
                } @catch (NSException *e) {
                    raisedObject = e;
                }
            });

#if !CDR_SYMBOLICATION_AVAILABLE
            context(@"when symbolication is not available (devices)", ^{
                it(@"returns nil", ^{
                    symbols should be_nil;
                });

                it(@"sets not available error", ^{
                    error.domain should equal(kCDRSymbolicatorErrorDomain);
                    error.code should equal(kCDRSymbolicatorErrorNotAvailable);
                    [error.userInfo objectForKey:kCDRSymbolicatorErrorMessageKey] \
                        should be_instance_of([NSString class]).or_any_subclass();
                });
            });
#else
            context(@"when symbolication is available (mac, simulator)", ^{
                context(@"when symbolication is successful", ^{
                    it(@"returns string with symbolicated call stack "
                        "showing originating error location closest to the top", ^{
                         symbols should contain(
                            @"  *CDRSpecFailureSpec.mm:156\n"
                             "  *CDRSpecFailureSpec.mm:162\n"
                        );
                    });

                    it(@"indicates unsymbolicated portions of call stack with '...'", ^{
                         symbols should contain(
                            @"Call stack:\n"
                             "  ...\n"                   // <-+ objc_exception_throw,
                             "  *CDRSpecFailureSpec.mm"  //   | [NSException raise:...], etc.
                        );
                    });

                    it(@"includes asterisk before every path "
                        "because paths are not absolute and "
                        "Xcode plugins need to be able to recognize them", ^{
                        symbols should contain(@"*CDRSpecFailureSpec.mm");
                    });

                    it(@"does not set error", ^{
                        error should be_nil;
                    });
                });

                context(@"when symbolication is not successful", ^{
                    beforeEach(^{
                        NSNumber *badAddress = [NSNumber numberWithUnsignedInteger:123];
                        NSArray *addresses = [NSArray arrayWithObject:badAddress];
                        spy_on(raisedObject);
                        raisedObject stub_method("callStackReturnAddresses").and_return(addresses);
                    });

                    it(@"returns nil", ^{
                        symbols should be_nil;
                    });

                    it(@"sets not successful error", ^{
                        error.domain should equal(kCDRSymbolicatorErrorDomain);
                        error.code should equal(kCDRSymbolicatorErrorNotSuccessful);
                        [error.userInfo objectForKey:kCDRSymbolicatorErrorMessageKey] \
                            should be_instance_of([NSString class]).or_any_subclass();
                    });
                });
            });
#endif
        });

        context(@"when raised object does not provide call stack return addresses", ^{
            beforeEach(^{ raisedObject = @"failure"; });

            it(@"returns nil", ^{
                symbols should be_nil;
            });
        });
    });
});

SPEC_END
