#if TARGET_OS_IPHONE
#import <Cedar/CDRSpecHelper.h>
#else
#import <Cedar/CDRSpecHelper.h>
#endif

extern "C" {
#import "ExpectFailureWithMessage.h"
}

using namespace Cedar::Matchers;

SPEC_BEGIN(BeGreaterThanSpec)

describe(@"be_greater_than matcher", ^{
    int someInteger = 10;

    describe(@"when the actual value is a built-in type", ^{
        int actualValue = someInteger;

        describe(@"and the expected value is the same built-in type", ^{
            __block int expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = 1;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = 100;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = actualValue;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is a different, but comparable, built-in type", ^{
            __block float expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = 1.1;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1.1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = 100.1;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100.1>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = actualValue;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSNumber *", ^{
            __block NSNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = @1;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = @100;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = @(actualValue);
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSDecimalNumber *", ^{
            __block NSDecimalNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"1.1"];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1.1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"100.1"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100.1>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"10"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSDecimal", ^{
            __block NSDecimal expectedValue;
            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [@1.5f decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1.5>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [@100.5f decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100.5>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [@10 decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an id", ^{
        id actualValue = @(someInteger);

        describe(@"and the expected value is declared as an NSNumber *", ^{
            __block NSNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = @1;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = @100;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [[actualValue copy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSDecimalNumber *", ^{
            __block NSDecimalNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"1.1"];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1.1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"100.1"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100.1>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"10"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSDecimal", ^{
            __block NSDecimal expectedValue;
            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [@1.5f decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1.5>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [@100.5f decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100.5>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [@10 decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an NSObject *", ^{
        NSObject *actualValue = @(someInteger);

        describe(@"and the expected value is declared as an NSNumber *", ^{
            __block NSNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = @1;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = @100;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [[actualValue copy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSDecimalNumber *", ^{
            __block NSDecimalNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"1.1"];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1.1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"100.1"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100.1>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"10"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSDecimal", ^{
            __block NSDecimal expectedValue;
            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [@1.5f decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1.5>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [@100.5f decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100.5>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [@10 decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an NSValue *", ^{
        NSValue *actualValue = @(someInteger);

        describe(@"and the expected value is declared as an NSNumber *", ^{
            __block NSNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = @1;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = @100;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [[actualValue copy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSDecimalNumber *", ^{
            __block NSDecimalNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"1.1"];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1.1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"100.1"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100.1>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"10"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSDecimal", ^{
            __block NSDecimal expectedValue;
            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [@1.5f decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1.5>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [@100.5f decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100.5>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [@10 decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an NSNumber *", ^{
        NSNumber *actualValue = @(someInteger);

        describe(@"and the expected value is declared as an NSNumber *", ^{
            __block NSNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = @1;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = @100;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [[actualValue copy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSObject *", ^{
            __block NSObject *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = @1;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = @100;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [[actualValue copy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSValue *", ^{
            __block NSValue *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = @1;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = @100;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [[actualValue copy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an id", ^{
            __block id expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = @1;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = @100;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [[actualValue copy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as a integer built-in type", ^{
            __block long long expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = 1;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = 100;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = someInteger;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as a floating point built-in type", ^{
            __block double expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = 1.1;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1.1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = 100.1;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100.1>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = someInteger / 1.0;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSDecimalNumber *", ^{
            __block NSDecimalNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"1.1"];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1.1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"100.1"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100.1>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"10"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSDecimal", ^{
            __block NSDecimal expectedValue;
            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [@1.5f decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1.5>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [@100.5f decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100.5>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [actualValue decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an NSDecimalNumber *", ^{
        NSDecimalNumber *actualValue = [NSDecimalNumber decimalNumberWithDecimal:[@10.f decimalValue]];

        describe(@"and the expected value is declared as an NSDecimalNumber *", ^{
            __block NSDecimalNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithDecimal:[@1.5f decimalValue]];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1.5>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithDecimal:[@100.5f decimalValue]];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100.5>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [[actualValue copy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSNumber *", ^{
            __block NSNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithDecimal:[@1.f decimalValue]];//[NSNumber numberWithInt:1];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithDecimal:[@100.f decimalValue]];//[NSNumber numberWithInt:100];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [[actualValue copy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSObject *", ^{
            __block NSObject *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithDecimal:[@1.5f decimalValue]];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1.5>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithDecimal:[@100.5f decimalValue]];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100.5>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [[actualValue copy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSValue *", ^{
            __block NSValue *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithDecimal:[@1 decimalValue]];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithDecimal:[@100 decimalValue]];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [[actualValue copy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an id", ^{
            __block id expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithDecimal:[@1 decimalValue]];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithDecimal:[@100 decimalValue]];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [[actualValue copy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as a integer built-in type", ^{
            __block long long expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = 1;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = 100;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = someInteger;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as a floating point built-in type", ^{
            __block double expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = 1.1;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1.1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = 100.1f;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100.1>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = someInteger / 1.f;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSDecimal", ^{
            __block NSDecimal expectedValue;
            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [@1.5f decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1.5>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [@100.5f decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100.5>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [actualValue decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an NSDecimal", ^{
        NSDecimal actualValue = [@10.f decimalValue];

        describe(@"and the expected value is declared as an NSDecimal", ^{
            __block NSDecimal expectedValue;
            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [@1.5f decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1.5>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [@100.5f decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100.5>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = actualValue;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSDecimalNumber *", ^{
            __block NSDecimalNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithDecimal:[@1.5f decimalValue]];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1.5>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithDecimal:[@100.5f decimalValue]];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100.5>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithDecimal:actualValue];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSNumber *", ^{
            __block NSNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = @1;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = @100;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = @10;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSObject *", ^{
            __block NSObject *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithDecimal:[@1.5f decimalValue]];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1.5>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithDecimal:[@100.5f decimalValue]];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100.5>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = @10;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSValue *", ^{
            __block NSValue *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = @1;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = @100;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = @10;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an id", ^{
            __block id expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = @1;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = @100;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = @10;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as a integer built-in type", ^{
            __block long long expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = 1;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = 100;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = someInteger;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as a floating point built-in type", ^{
            __block double expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = 1.1;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_greater_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than <1.1>", ^{
                            expect(actualValue).to_not(be_greater_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = 100.1f;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <100.1>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = someInteger / 1.f;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                            expect(actualValue).to(be_greater_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_greater_than(expectedValue));
                    });
                });
            });
        });
    });
});

describe(@"> operator matcher", ^{
    describe(@"when the actual value is greater than the expected value", ^{
        it(@"should pass", ^{
            expect(10) > 1;
        });
    });

    describe(@"when the actual value is less than the expected value", ^{
        it(@"should fail with a sensible failure message", ^{
            expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                expect(10) > 100;
            });
        });
    });

    describe(@"when the actual value equals the expected value", ^{
        it(@"should fail with a sensible failure message", ^{
            expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                expect(10) > 10;
            });
        });
    });

    describe(@"with and without 'to'", ^{
        int actualValue = 10, expectedValue = 1;

        describe(@"positive match", ^{
            it(@"should pass", ^{
                expect(actualValue) > expectedValue;
                expect(actualValue).to > expectedValue;
            });
        });

        describe(@"negative match", ^{
            it(@"should fail with a sensible failure message", ^{
                expectFailureWithMessage(@"Expected <10> to not be greater than <1>", ^{
                    expect(actualValue).to_not > expectedValue;
                });
            });
        });
    });
});

SPEC_END
