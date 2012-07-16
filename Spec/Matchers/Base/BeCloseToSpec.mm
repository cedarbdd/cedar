#if TARGET_OS_IPHONE
#import <Cedar/SpecHelper.h>
#else
#import <Cedar/SpecHelper.h>
#endif

extern "C" {
#import "ExpectFailureWithMessage.h"
}

using namespace Cedar::Matchers;

SPEC_BEGIN(BeCloseToSpec)

describe(@"be_close_to matcher", ^{
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
    });

    describe(@"when the actual value is declared as an NSNumber *", ^{

        NSNumber *actualValue = [NSNumber numberWithFloat:2.0 / 3.0 ];

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
    });
});

SPEC_END
