#import "Cedar.h"
#import "ExpectFailureWithMessage.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(MutableEqualSpec)

describe(@"equal matcher", ^{
    describe(@"when the actual value is an NSString *", ^{
        NSString *actualValue = @"wibble";

        describe(@"and the expected value is an NSMutableString *", ^{
            __block NSMutableString *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSMutableString stringWithString:actualValue];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not equal <%@>", actualValue, expectedValue], ^{
                            expect(actualValue).to_not(equal(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSMutableString stringWithString:@"wobble"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to equal <%@>", actualValue, expectedValue], ^{
                            expect(actualValue).to(equal(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(equal(expectedValue));
                    });
                });
            });
        });
    });

    describe(@"when the actual value is an NSMutableString *", ^{
        NSMutableString *actualValue = [NSMutableString stringWithString:@"wibble"];

        describe(@"and the expected value is an NSString *", ^{
            __block NSString *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSString stringWithString:actualValue];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not equal <%@>", actualValue, expectedValue], ^{
                            expect(actualValue).to_not(equal(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSMutableString stringWithString:@"wobble"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to equal <%@>", actualValue, expectedValue], ^{
                            expect(actualValue).to(equal(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(equal(expectedValue));
                    });
                });
            });
        });
    });
});

SPEC_END
