#if TARGET_OS_IPHONE
#import <Cedar/SpecHelper.h>
#import "OCMock.h"
#else
#import <Cedar/SpecHelper.h>
#import <OCMock/OCMock.h>
#endif

extern "C" {
#import "ExpectFailureWithMessage.h"
}

using namespace Cedar::Matchers;

SPEC_BEGIN(BeGreaterThanOperatorSpec)

describe(@"> operator matcher", ^{
    int someInteger = 10;

    describe(@"when the actual value is a built-in type", ^{
        int actualValue = someInteger;

        describe(@"and the expected value is the same built-in type", ^{
            __block int expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = 1;
                });

                it(@"should pass", ^{
                    expect(actualValue) > expectedValue;
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = 100;
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                        expect(actualValue) > expectedValue;
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = actualValue;
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                        expect(actualValue) > expectedValue;
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

                it(@"should pass", ^{
                    expect(actualValue) > expectedValue;
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = 100.1;
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <100.1>", ^{
                        expect(actualValue) > expectedValue;
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = actualValue;
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                        expect(actualValue) > expectedValue;
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSNumber", ^{
            __block NSNumber *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:1];
                });

                it(@"should pass", ^{
                    expect(actualValue) > expectedValue;
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:100];
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                        expect(actualValue) > expectedValue;
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:actualValue];
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                        expect(actualValue) > expectedValue;
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
                    expectedValue = [NSNumber numberWithInt:1];
                });

                it(@"should pass", ^{
                    expect(actualValue) > expectedValue;
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:100];
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                        expect(actualValue) > expectedValue;
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [[actualValue copy] autorelease];
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                        expect(actualValue) > expectedValue;
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
                    expectedValue = [NSNumber numberWithInt:1];
                });

                it(@"should pass", ^{
                    expect(actualValue) > expectedValue;
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:100];
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                        expect(actualValue) > expectedValue;
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [[actualValue copy] autorelease];
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                        expect(actualValue) > expectedValue;
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
                    expectedValue = [NSNumber numberWithInt:1];
                });

                it(@"should pass", ^{
                    expect(actualValue) > expectedValue;
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:100];
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                        expect(actualValue) > expectedValue;
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [[actualValue copy] autorelease];
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                        expect(actualValue) > expectedValue;
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
                    expectedValue = [NSNumber numberWithInt:1];
                });

                it(@"should pass", ^{
                    expect(actualValue) > expectedValue;
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:100];
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                        expect(actualValue) > expectedValue;
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [[actualValue copy] autorelease];
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                        expect(actualValue) > expectedValue;
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSObject *", ^{
            __block NSObject *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:1];
                });

                it(@"should pass", ^{
                    expect(actualValue) > expectedValue;
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:100];
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                        expect(actualValue) > expectedValue;
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [[actualValue copy] autorelease];
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                        expect(actualValue) > expectedValue;
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSValue *", ^{
            __block NSValue *expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:1];
                });

                it(@"should pass", ^{
                    expect(actualValue) > expectedValue;
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:100];
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                        expect(actualValue) > expectedValue;
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [[actualValue copy] autorelease];
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                        expect(actualValue) > expectedValue;
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an id", ^{
            __block id expectedValue;

            describe(@"and the actual value is greater than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:1];
                });

                it(@"should pass", ^{
                    expect(actualValue) > expectedValue;
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:100];
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                        expect(actualValue) > expectedValue;
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = [[actualValue copy] autorelease];
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                        expect(actualValue) > expectedValue;
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

                it(@"should pass", ^{
                    expect(actualValue) > expectedValue;
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = 100;
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <100>", ^{
                        expect(actualValue) > expectedValue;
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = someInteger;
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                        expect(actualValue) > expectedValue;
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

                it(@"should pass", ^{
                    expect(actualValue) > expectedValue;
                });
            });

            describe(@"and the actual value is less than the expected value", ^{
                beforeEach(^{
                    expectedValue = 100.1;
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <100.1>", ^{
                        expect(actualValue) > expectedValue;
                    });
                });
            });

            describe(@"and the actual value equals the expected value", ^{
                beforeEach(^{
                    expectedValue = someInteger / 1.0;
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <10> to be greater than <10>", ^{
                        expect(actualValue) > expectedValue;
                    });
                });
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
