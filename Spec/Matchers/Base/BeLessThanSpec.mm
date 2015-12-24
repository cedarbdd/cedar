#import "Cedar.h"
#import "ExpectFailureWithMessage.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(BeLessThanSpec)

describe(@"be_less_than matcher", ^{
    int someInteger = 10;

    describe(@"when the actual value is a built-in type", ^{
        int actualValue = someInteger;

        describe(@"and the expected value is the same built-in type", ^{
            __block int expectedValue;

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = someInteger * 10;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_less_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be less than <100>", ^{
                            expect(actualValue).to_not(be_less_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = someInteger / 10;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <1>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = actualValue;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <10>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is a different, but comparable, built-in type", ^{
            __block float expectedValue;

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = someInteger * 10.0;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_less_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be less than <100>", ^{
                            expect(actualValue).to_not(be_less_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = someInteger / 10.0;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <1>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = someInteger * 1.0;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <10>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an id", ^{
        id actualValue = [NSNumber numberWithInt:someInteger];

        describe(@"and the expected value is declared as an NSNumber *", ^{
            __block NSNumber *expectedValue;

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger * 10];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_less_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be less than <100>", ^{
                            expect(actualValue).to_not(be_less_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger / 10];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <1>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <10>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSDecimalNumber *", ^{
            __block NSDecimalNumber *expectedValue;

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"100.1"];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_less_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be less than <100.1>", ^{
                            expect(actualValue).to_not(be_less_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"1.1"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <1.1>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"10"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <10>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an NSObject *", ^{
        NSObject *actualValue = [NSNumber numberWithInt:someInteger];

        describe(@"and the expected value is declared as an NSNumber *", ^{
            __block NSNumber *expectedValue;

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger * 10];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_less_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be less than <100>", ^{
                            expect(actualValue).to_not(be_less_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger / 10];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <1>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <10>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSDecimalNumber *", ^{
            __block NSDecimalNumber *expectedValue;

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"100.1"];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_less_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be less than <100.1>", ^{
                            expect(actualValue).to_not(be_less_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"1.1"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <1.1>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"10"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <10>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an NSValue *", ^{
        NSValue *actualValue = [NSNumber numberWithInt:someInteger];

        describe(@"and the expected value is declared as an NSNumber *", ^{
            __block NSNumber *expectedValue;

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger * 10];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_less_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be less than <100>", ^{
                            expect(actualValue).to_not(be_less_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger / 10];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <1>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <10>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSDecimalNumber *", ^{
            __block NSDecimalNumber *expectedValue;

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"100.1"];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_less_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be less than <100.1>", ^{
                            expect(actualValue).to_not(be_less_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"1.1"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <1.1>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"10"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <10>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an NSNumber *", ^{
        NSNumber *actualValue = [NSNumber numberWithInt:someInteger];

        describe(@"and the expected value is declared as an NSNumber *", ^{
            __block NSNumber *expectedValue;

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger * 10];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_less_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be less than <100>", ^{
                            expect(actualValue).to_not(be_less_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger / 10];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <1>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <10>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSObject *", ^{
            __block NSObject *expectedValue;

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger * 10];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_less_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be less than <100>", ^{
                            expect(actualValue).to_not(be_less_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger / 10];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <1>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <10>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSValue *", ^{
            __block NSValue *expectedValue;

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger * 10];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_less_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be less than <100>", ^{
                            expect(actualValue).to_not(be_less_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger / 10];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <1>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <10>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an id", ^{
            __block id expectedValue;

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger * 10];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_less_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be less than <100>", ^{
                            expect(actualValue).to_not(be_less_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger / 10];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <1>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <10>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSDecimalNumber *", ^{
            __block NSDecimalNumber *expectedValue;

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"100.1"];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_less_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be less than <100.1>", ^{
                            expect(actualValue).to_not(be_less_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"1.1"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <1.1>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"10"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <10>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an NSDecimalNumber *", ^{
        NSDecimalNumber *actualValue = [NSDecimalNumber decimalNumberWithDecimal:[@(someInteger) decimalValue]];

        describe(@"and the expected value is declared as an NSNumber *", ^{
            __block NSNumber *expectedValue;

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger * 10];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_less_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be less than <100>", ^{
                            expect(actualValue).to_not(be_less_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger / 10];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <1>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <10>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSObject *", ^{
            __block NSObject *expectedValue;

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger * 10];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_less_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be less than <100>", ^{
                            expect(actualValue).to_not(be_less_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger / 10];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <1>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <10>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSValue *", ^{
            __block NSValue *expectedValue;

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger * 10];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_less_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be less than <100>", ^{
                            expect(actualValue).to_not(be_less_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger / 10];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <1>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <10>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an id", ^{
            __block id expectedValue;

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger * 10];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_less_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be less than <100>", ^{
                            expect(actualValue).to_not(be_less_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger / 10];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <1>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <10>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSDecimalNumber *", ^{
            __block NSDecimalNumber *expectedValue;

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"100.1"];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_less_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be less than <100.1>", ^{
                            expect(actualValue).to_not(be_less_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"1.1"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <1.1>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"10"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <10>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an NSDecimal", ^{
        NSDecimal actualValue = [@10.f decimalValue];

        describe(@"and the expected value is declared as an NSDecimal", ^{
            __block NSDecimal expectedValue;

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [@100.5f decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_less_than(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be less than <100.5>", ^{
                            expect(actualValue).to_not(be_less_than(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [@1.5f decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <1.5>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = actualValue;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be less than <10>", ^{
                            expect(actualValue).to(be_less_than(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_less_than(expectedValue));
                    });
                });
            });
        });
    });

    describe(@"when the expected value is nill", ^{
        it(@"should alert the user that the probaby did not mean to verify the value was less than nill", ^{
            expectFailureWithMessage(@"Unexpected use of be_less_than matcher to check for nil; use the be_nil matcher to match nil values", ^{
                NSNumber * value = @1.0f;
                NSNumber * expectedValue = nil;
                value should be_less_than(expectedValue);
            });
        });
    });
});

//describe(@"< operator matcher", ^{
//    describe(@"when the actual value is less than the expected value", ^{
//        it(@"should pass", ^{
//            expect(1) < 10;
//        });
//    });
//
//    describe(@"when the actual value is greater than the expected value", ^{
//        it(@"should fail with a sensible failure message", ^{
//            expectFailureWithMessage(@"Expected <10> to be less than <1>", ^{
//                expect(10) < 1;
//            });
//        });
//    });
//
//    describe(@"when the actual value equals the expected value", ^{
//        it(@"should fail with a sensible failure message", ^{
//            expectFailureWithMessage(@"Expected <10> to be less than <10>", ^{
//                expect(10) < 10;
//            });
//        });
//    });
//
//    describe(@"with and without 'to'", ^{
//        int actualValue = 1, expectedValue = 10;
//
//        describe(@"positive match", ^{
//            it(@"should pass", ^{
//                expect(actualValue) < expectedValue;
//                expect(actualValue).to < expectedValue;
//            });
//        });
//
//        describe(@"negative match", ^{
//            it(@"should fail with a sensible failure message", ^{
//                expectFailureWithMessage(@"Expected <1> to not be less than <10>", ^{
//                    expect(actualValue).to_not < expectedValue;
//                });
//            });
//        });
//    });
//});

SPEC_END
