#import "Cedar.h"
#import "ExpectFailureWithMessage.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(BeCloseToSpec)

describe(@"be_close_to matcher", ^{
    describe(@"when the actual value and expected value are declared as NSDates", ^{
        __block NSDate *expectedValue;
        NSDate *actualValue = [NSDate dateWithTimeIntervalSince1970:1];

        describe(@"with an explicit threshold", ^{
            NSTimeInterval threshold = 0.1;

            describe(@"and the values are within a given threshold", ^{
                beforeEach(^{
                    expectedValue = [NSDate dateWithTimeIntervalSince1970:1.09];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        actualValue should be_close_to(expectedValue).within(threshold);
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <1970-01-01 00:00:01 +0000 (1.000000)> to not be close to <1970-01-01 00:00:01 +0000 (1.090000)> (within 0.1)", ^{
                            actualValue should_not be_close_to(expectedValue).within(threshold);
                        });
                    });
                });
            });

            context(@"and the values are not within the given threshold", ^{
                beforeEach(^{
                    expectedValue = [NSDate dateWithTimeIntervalSince1970:2];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <1970-01-01 00:00:01 +0000 (1.000000)> to be close to <1970-01-01 00:00:02 +0000 (2.000000)> (within 0.1)", ^{
                            actualValue should be_close_to(expectedValue).within(threshold);
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        actualValue should_not be_close_to(expectedValue).within(threshold);
                    });
                });
            });
        });

        describe(@"without an explicit threshold", ^{
            describe(@"and the values are within the default threshold", ^{
                beforeEach(^{
                    expectedValue = [NSDate dateWithTimeIntervalSince1970:1.009];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        actualValue should be_close_to(expectedValue);
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <1970-01-01 00:00:01 +0000 (1.000000)> to not be close to <1970-01-01 00:00:01 +0000 (1.009000)> (within 0.01)", ^{
                            actualValue should_not be_close_to(expectedValue);
                        });
                    });
                });
            });

            context(@"and the values are not within the default threshold", ^{
                beforeEach(^{
                    expectedValue = [NSDate dateWithTimeIntervalSince1970:2];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <1970-01-01 00:00:01 +0000 (1.000000)> to be close to <1970-01-01 00:00:02 +0000 (2.000000)> (within 0.01)", ^{
                            actualValue should be_close_to(expectedValue);
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        actualValue should_not be_close_to(expectedValue);
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as a float", ^{
        float actualValue = 2.0 / 3.0;

        describe(@"and the expected value is also a float", ^{
            __block float expectedValue;

            describe(@"with an explicit threshold", ^{
                float threshold = 0.1;

                describe(@"and the values are within the given threshold", ^{
                    beforeEach(^{
                        expectedValue = 2.0 / 3.0 + 0.01;
                    });

                    describe(@"positive match", ^{
                        it(@"should pass", ^{
                            expect(actualValue).to(be_close_to(expectedValue).within(threshold));
                        });
                    });

                    describe(@"negative match", ^{
                        it(@"should fail with a sensible failure message", ^{
                            expectFailureWithMessage(@"Expected <0.666667> to not be close to <0.676667> (within 0.1)", ^{
                                expect(actualValue).to_not(be_close_to(expectedValue).within(threshold));
                            });
                        });
                    });
                });

                describe(@"and the values are not within the given threshold", ^{
                    beforeEach(^{
                        expectedValue = 2.0 / 3.0 + 0.2;
                    });

                    describe(@"positive match", ^{
                        it(@"should fail with a sensible failure message", ^{
                            expectFailureWithMessage(@"Expected <0.666667> to be close to <0.866667> (within 0.1)", ^{
                                expect(actualValue).to(be_close_to(expectedValue).within(threshold));
                            });
                        });
                    });

                    describe(@"negative match", ^{
                        it(@"should pass", ^{
                            expect(actualValue).to_not(be_close_to(expectedValue).within(threshold));
                        });
                    });
                });
            });

            describe(@"without an explicit threshold", ^{
                describe(@"and the values are within the default threshold", ^{
                    beforeEach(^{
                        expectedValue = 2.0 / 3.0 + 0.000001;
                    });

                    describe(@"positive match", ^{
                        it(@"should pass", ^{
                            expect(actualValue).to(be_close_to(expectedValue));
                        });
                    });

                    describe(@"negative match", ^{
                        it(@"should fail with a sensible failure message", ^{
                            expectFailureWithMessage(@"Expected <0.666667> to not be close to <0.666668> (within 0.01)", ^{
                                expect(actualValue).to_not(be_close_to(expectedValue));
                            });
                        });
                    });
                });

                describe(@"and the values are not within the default threshold", ^{
                    beforeEach(^{
                        expectedValue = 2.0 / 3.0 + 0.1;
                    });

                    describe(@"positive match", ^{
                        it(@"should fail with a sensible failure message", ^{
                            expectFailureWithMessage(@"Expected <0.666667> to be close to <0.766667> (within 0.01)", ^{
                                expect(actualValue).to(be_close_to(expectedValue));
                            });
                        });
                    });

                    describe(@"negative match", ^{
                        it(@"should pass", ^{
                            expect(actualValue).to_not(be_close_to(expectedValue));
                        });
                    });
                });
            });
        });

        describe(@"and the expected value is a compatible non-float type", ^{
            __block int expectedValue;
            float threshold = 1;

            describe(@"and the values are within the given threshold", ^{
                beforeEach(^{
                    expectedValue = 1;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_close_to(expectedValue).within(threshold));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <0.666667> to not be close to <1> (within 1)", ^{
                            expect(actualValue).to_not(be_close_to(expectedValue).within(threshold));
                        });
                    });
                });
            });

            describe(@"and the values are not within the given threshold", ^{
                beforeEach(^{
                    expectedValue = 5;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <0.666667> to be close to <5> (within 1)", ^{
                            expect(actualValue).to(be_close_to(expectedValue).within(threshold));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_close_to(expectedValue).within(threshold));
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an id", ^{
        id actualValue = [NSNumber numberWithFloat:2.0 / 3.0 ];

        describe(@"and the expected value is an id", ^{
            __block id expectedValue;
            float threshold = 0.1;

            describe(@"and the values are within the given threshold", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithFloat:2.0 / 3.0 + 0.1];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_close_to(expectedValue).within(threshold));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <0.6666667> to not be close to <0.7666667> (within 0.1)", ^{
                            expect(actualValue).to_not(be_close_to(expectedValue).within(threshold));
                        });
                    });
                });
            });

            describe(@"and the values are not within the given threshold", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithFloat:2.0 / 3.0 + 0.2];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <0.6666667> to be close to <0.8666667> (within 0.1)", ^{
                            expect(actualValue).to(be_close_to(expectedValue).within(threshold));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_close_to(expectedValue).within(threshold));
                    });
                });
            });
        });

        describe(@"and the expected value is an NSDecimalNumber *", ^{
            __block NSDecimalNumber *expectedValue;
            float threshold = 0.1;

            describe(@"and the values are within the given threshold", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithDecimal:[@(2.0 / 3.0 + 0.1) decimalValue]];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_close_to(expectedValue).within(threshold));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <0.6666667> to not be close to <0.7666666666666666> (within 0.1)", ^{
                            expect(actualValue).to_not(be_close_to(expectedValue).within(threshold));
                        });
                    });
                });
            });

            describe(@"and the values are not within the given threshold", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithDecimal:[@(2.0 / 3.0 + 0.2) decimalValue]];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <0.6666667> to be close to <0.8666666666666667> (within 0.1)", ^{
                            expect(actualValue).to(be_close_to(expectedValue).within(threshold));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_close_to(expectedValue).within(threshold));
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an NSNumber *", ^{
        NSNumber *actualValue = [NSNumber numberWithFloat:2.0 / 3.0 ];

        describe(@"and the expected value is an NSNumber *", ^{
            __block NSNumber *expectedValue;
            float threshold = 0.1;

            describe(@"and the values are within the given threshold", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithFloat:2.0 / 3.0 + 0.1];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_close_to(expectedValue).within(threshold));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <0.666667> to not be close to <0.766667> (within 0.1)", ^{
                            expect(actualValue).to_not(be_close_to(expectedValue).within(threshold));
                        });
                    });
                });
            });

            describe(@"and the values are not within the given threshold", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithFloat:2.0 / 3.0 + 0.2];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <0.666667> to be close to <0.866667> (within 0.1)", ^{
                            expect(actualValue).to(be_close_to(expectedValue).within(threshold));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_close_to(expectedValue).within(threshold));
                    });
                });
            });
        });

        describe(@"and the expected value is an NSDecimalNumber *", ^{
            __block NSDecimalNumber *expectedValue;
            float threshold = 0.1;

            describe(@"and the values are within the given threshold", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithDecimal:[@(2.0 / 3.0 + 0.1) decimalValue]];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_close_to(expectedValue).within(threshold));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <0.666667> to not be close to <0.7666666666666666> (within 0.1)", ^{
                            expect(actualValue).to_not(be_close_to(expectedValue).within(threshold));
                        });
                    });
                });
            });

            describe(@"and the values are not within the given threshold", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithDecimal:[@(2.0 / 3.0 + 0.2) decimalValue]];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <0.666667> to be close to <0.8666666666666667> (within 0.1)", ^{
                            expect(actualValue).to(be_close_to(expectedValue).within(threshold));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_close_to(expectedValue).within(threshold));
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an NSDecimalNumber *", ^{
        NSDecimalNumber *actualValue = [NSDecimalNumber decimalNumberWithDecimal:[@(2.0 / 3.0) decimalValue]];

        describe(@"and the expected value is an NSNumber *", ^{
            __block NSNumber *expectedValue;
            float threshold = 0.1;

            describe(@"and the values are within the given threshold", ^{
                beforeEach(^{
                    //We need to use a delta smaller than the threshold to account for non-decimals having less precision
                    expectedValue = [NSNumber numberWithFloat:2.0 / 3.0 + 0.09];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_close_to(expectedValue).within(threshold));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <0.6666666666666666> to not be close to <0.756667> (within 0.1)", ^{
                            expect(actualValue).to_not(be_close_to(expectedValue).within(threshold));
                        });
                    });
                });
            });

            describe(@"and the values are not within the given threshold", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithFloat:2.0 / 3.0 + 0.2];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <0.6666666666666666> to be close to <0.866667> (within 0.1)", ^{
                            expect(actualValue).to(be_close_to(expectedValue).within(threshold));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_close_to(expectedValue).within(threshold));
                    });
                });
            });
        });

        describe(@"and the expected value is an NSDecimalNumber *", ^{
            __block NSDecimalNumber *expectedValue;
            float threshold = 0.1;

            describe(@"and the values are within the given threshold", ^{
                beforeEach(^{
                    expectedValue = [[NSDecimalNumber decimalNumberWithDecimal:[@(2.0 / 3.0) decimalValue]] decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[@(0.1) decimalValue]]];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_close_to(expectedValue).within(threshold));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <0.6666666666666666> to not be close to <0.7666666666666666> (within 0.1)", ^{
                            expect(actualValue).to_not(be_close_to(expectedValue).within(threshold));
                        });
                    });
                });
            });

            describe(@"and the values are not within the given threshold", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithDecimal:[@(2.0 / 3.0 + 0.2) decimalValue]];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <0.6666666666666666> to be close to <0.8666666666666667> (within 0.1)", ^{
                            expect(actualValue).to(be_close_to(expectedValue).within(threshold));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_close_to(expectedValue).within(threshold));
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an NSDecimal", ^{
        NSDecimal actualValue = [@(2.0 / 3.0) decimalValue];

        describe(@"and the expected value is an NSDecimal", ^{
            __block NSDecimal expectedValue;
            float threshold = 0.1;

            describe(@"and the values are within the given threshold", ^{
                beforeEach(^{
                    NSDecimal lhs = [@(2.0 / 3.0) decimalValue];
                    NSDecimal rhs = [@0.1 decimalValue];
                    NSDecimalAdd(&expectedValue, &lhs, &rhs, NSRoundPlain);
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(be_close_to(expectedValue).within(threshold));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <0.6666666666666666> to not be close to <0.7666666666666666> (within 0.1)", ^{
                            expect(actualValue).to_not(be_close_to(expectedValue).within(threshold));
                        });
                    });
                });
            });

            describe(@"and the values are not within the given threshold", ^{
                beforeEach(^{
                    NSDecimal lhs = [@(2.0 / 3.0) decimalValue];
                    NSDecimal rhs = [@0.2 decimalValue];
                    NSDecimalAdd(&expectedValue, &lhs, &rhs, NSRoundPlain);
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <0.6666666666666666> to be close to <0.8666666666666666> (within 0.1)", ^{
                            expect(actualValue).to(be_close_to(expectedValue).within(threshold));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to_not(be_close_to(expectedValue).within(threshold));
                    });
                });
            });
        });
    });

    describe(@"when the actual value is not a valid type to compare", ^{
        describe(@"positive match", ^{
            it(@"should fail", ^{
                expectFailureWithMessage(@"Actual value <1.0> (__NSCFConstantString) is not a numeric value (NSNumber, NSDate, float, etc.)", ^{
                    NSNumber *value = [@[@"1.0"] firstObject];
                    value should be_close_to(@1.0001);
                });
            });
        });

        describe(@"negative match", ^{
            it(@"should fail", ^{
                expectFailureWithMessage(@"Actual value <1.0> (__NSCFConstantString) is not a numeric value (NSNumber, NSDate, float, etc.)", ^{
                    NSNumber *value = [@[@"1.0"] firstObject];
                    value should_not be_close_to(@1.0001);
                });
            });
        });
    });

    describe(@"when the expected value is nil", ^{
        it(@"should alert the user that they probably did not mean to verify the value was close to nil", ^{
            expectFailureWithMessage(@"Unexpected use of be_close_to matcher to check for nil; use the be_nil matcher to match nil values", ^{
                NSNumber *value = @1.0f;
                NSNumber *expectedValue = nil;
                value should be_close_to(expectedValue);
            });
        });
    });
});

SPEC_END
