#import "Cedar.h"
#import "ExpectFailureWithMessage.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(BeGTESpec)

describe(@"be_gte matcher", ^{
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
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <1>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
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
                        expectFailureWithMessage(@"Expected <10> to be greater than or equal to <100>", ^{
                            expect(actualValue).to(be_gte(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_gte(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = actualValue;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <10>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
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
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <1.1>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
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
                        expectFailureWithMessage(@"Expected <10> to be greater than or equal to <100.1>", ^{
                            expect(actualValue).to(be_gte(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_gte(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = someInteger / 1.0;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <10>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an id", ^{
        id actualValue = [NSNumber numberWithInt:someInteger];

        describe(@"and the expected value is declared as an NSNumber *", ^{
            __block NSNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger / 10];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <1>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger * 10];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than or equal to <100>", ^{
                            expect(actualValue).to(be_gte(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_gte(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <10>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSDecimalNumber", ^{
            __block NSDecimalNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"1"];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <1>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"100"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than or equal to <100>", ^{
                            expect(actualValue).to(be_gte(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_gte(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"10"];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <10>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an NSObject *", ^{
        NSObject *actualValue = [NSNumber numberWithInt:someInteger];

        describe(@"and the expected value is declared as an NSNumber *", ^{
            __block NSNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger / 10];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <1>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger * 10];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than or equal to <100>", ^{
                            expect(actualValue).to(be_gte(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_gte(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <10>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSDecimalNumber", ^{
            __block NSDecimalNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"1"];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <1>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"100"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than or equal to <100>", ^{
                            expect(actualValue).to(be_gte(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_gte(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"10"];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <10>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an NSValue *", ^{
        NSValue *actualValue = [NSNumber numberWithInt:someInteger];

        describe(@"and the expected value is declared as an NSNumber *", ^{
            __block NSNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger / 10];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <1>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger * 10];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than or equal to <100>", ^{
                            expect(actualValue).to(be_gte(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_gte(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <10>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSDecimalNumber", ^{
            __block NSDecimalNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"1"];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <1>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"100"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than or equal to <100>", ^{
                            expect(actualValue).to(be_gte(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_gte(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"10"];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <10>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an NSDecimalNumber *", ^{
        NSDecimalNumber *actualValue = [NSDecimalNumber decimalNumberWithString:@"10"];

        describe(@"and the expected value is declared as an NSNumber *", ^{
            __block NSNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger / 10];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <1>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger * 10];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than or equal to <100>", ^{
                            expect(actualValue).to(be_gte(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_gte(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <10>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSObject *", ^{
            __block NSObject *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger / 10];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <1>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger * 10];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than or equal to <100>", ^{
                            expect(actualValue).to(be_gte(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_gte(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <10>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSValue *", ^{
            __block NSValue *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger / 10];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <1>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger * 10];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than or equal to <100>", ^{
                            expect(actualValue).to(be_gte(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_gte(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <10>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an id", ^{
            __block id expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger / 10];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <1>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger * 10];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than or equal to <100>", ^{
                            expect(actualValue).to(be_gte(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_gte(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <10>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSDecimalNumber", ^{
            __block NSDecimalNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"1"];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <1>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"100"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than or equal to <100>", ^{
                            expect(actualValue).to(be_gte(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_gte(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"10"];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <10>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an NSNumber *", ^{
        NSNumber *actualValue = [NSNumber numberWithInt:someInteger];

        describe(@"and the expected value is declared as an NSNumber *", ^{
            __block NSNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger / 10];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <1>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger * 10];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than or equal to <100>", ^{
                            expect(actualValue).to(be_gte(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_gte(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <10>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSObject *", ^{
            __block NSObject *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger / 10];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <1>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger * 10];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than or equal to <100>", ^{
                            expect(actualValue).to(be_gte(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_gte(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <10>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSValue *", ^{
            __block NSValue *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger / 10];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <1>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger * 10];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than or equal to <100>", ^{
                            expect(actualValue).to(be_gte(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_gte(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <10>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an id", ^{
            __block id expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger / 10];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <1>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger * 10];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than or equal to <100>", ^{
                            expect(actualValue).to(be_gte(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_gte(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <10>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSDecimalNumber", ^{
            __block NSDecimalNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"1"];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <1>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"100"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than or equal to <100>", ^{
                            expect(actualValue).to(be_gte(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_gte(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"10"];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <10>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an NSDecimal", ^{
        NSDecimal actualValue = [@10 decimalValue];

        describe(@"and the expected value is declared as an NSDecimal", ^{
            __block NSDecimal expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [@1 decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <1>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [@100 decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to be greater than or equal to <100>", ^{
                            expect(actualValue).to(be_gte(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_gte(expectedValue));
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [@10 decimalValue];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_gte(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <10>", ^{
                            expect(actualValue).to_not(be_gte(expectedValue));
                        });
                    });
                });
            });
        });
    });


    describe(@"When the expected value is nil", ^{
        it(@"should alert the user that they probably did not mean to verify the value was >= nil", ^{
            expectFailureWithMessage(@"Unexpected use of be_greater_than_or_equal_to matcher to check for nil; use the be_nil matcher to match nil values",
                ^{
                    NSNumber *value = @0.0f;
                    NSNumber *expectedValue = nil;
                    value should be_greater_than_or_equal_to(expectedValue);
            });
        });
    });
});

describe(@"be_greater_than_or_equal_to matcher", ^{
    it(@"should have the same behavior as the be_gte matcher", ^{
        expect(10).to(be_greater_than_or_equal_to(1));

        expectFailureWithMessage(@"Expected <1> to be greater than or equal to <10>", ^{
            expect(1).to(be_greater_than_or_equal_to(10));
        });
    });
});

//describe(@">= operator matcher", ^{
//    describe(@"when the actual value is greater than the expected value", ^{
//        it(@"should pass", ^{
//            expect(10) >= 1;
//        });
//    });
//
//    describe(@"when the actual value is less than the expected value", ^{
//        it(@"should fail with a sensible failure message", ^{
//            expectFailureWithMessage(@"Expected <10> to be greater than or equal to <100>", ^{
//                expect(10) >= 100;
//            });
//        });
//    });
//
//    describe(@"when the actual value equals the expected value", ^{
//        it(@"should pass", ^{
//            expect(10) >= 10;
//        });
//    });
//
//    describe(@"with and without 'to'", ^{
//        int actualValue = 10, expectedValue = 1;
//
//        describe(@"positive match", ^{
//            it(@"should pass", ^{
//                expect(actualValue) >= expectedValue;
//                expect(actualValue).to >= expectedValue;
//            });
//        });
//
//        describe(@"negative match", ^{
//            it(@"should fail with a sensible failure message", ^{
//                expectFailureWithMessage(@"Expected <10> to not be greater than or equal to <1>", ^{
//                    expect(actualValue).to_not >= expectedValue;
//                });
//            });
//        });
//    });
//});

SPEC_END
