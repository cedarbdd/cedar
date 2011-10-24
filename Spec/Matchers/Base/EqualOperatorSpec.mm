
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

SPEC_BEGIN(EqualOperatorSpec)

describe(@"equality operator matcher", ^{
    describe(@"when the actual value is a built-in type", ^{
        int actualValue = 1;

        describe(@"and the expected value is the same built-in type", ^{
            __block int expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^ {
                    expectedValue = 1;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) == expectedValue;
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <1> to not equal <1>", ^{
                            expect(actualValue) != expectedValue;
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^ {
                    expectedValue = 147;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <1> to equal <147>", ^{
                            expect(actualValue) == expectedValue;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) != expectedValue;
                    });
                });
            });
        });

        describe(@"and the expected value is a different, but comparable, built-in type", ^{
            __block float expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^ {
                    expectedValue = 1.0;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) == expectedValue;
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <1> to not equal <1>", ^{
                            expect(actualValue) != expectedValue;
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^ {
                    expectedValue = 0.87;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <1> to equal <0.87>", ^{
                            expect(actualValue) == expectedValue;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) != expectedValue;
                    });
                });
            });
        });

        describe(@"and the expected value is an NSNumber", ^{
            __block NSNumber *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithFloat:1.0];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) == expectedValue;
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <1> to not equal <1>", ^{
                            expect(actualValue) != expectedValue;
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^ {
                    expectedValue = [NSNumber numberWithFloat:1.1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <1> to equal <1.1>", ^{
                            expect(actualValue) == expectedValue;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) != expectedValue;
                    });
                });
            });
        });
    });

    describe(@"when the actual value is a char type", ^{
        char actualValue = 1;

        it(@"should properly display any failure message", ^{
            expectFailureWithMessage(@"Expected <1> to equal <63>", ^{
                char expectedValue = 63;
                expect(actualValue) == expectedValue;
            });
        });
    });

    describe(@"when the actual value is declared as an id", ^{
        int someInteger = 7;
        id actualValue = [[[NSString alloc] initWithFormat:@"%d", someInteger] autorelease];

        describe(@"and the expected value is declared as an NSObject *", ^{
            __block NSObject *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [[actualValue mutableCopy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) == expectedValue;
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue) != expectedValue;
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSString stringWithFormat:@"%d", someInteger + 1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
                            expect(actualValue) == expectedValue;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) != expectedValue;
                    });
                });
            });
        });

        describe(@"and the expected value is also declared as an id", ^{
            __block id expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [[actualValue mutableCopy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) == expectedValue;
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue) != expectedValue;
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSString stringWithFormat:@"%d", someInteger + 1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
                            expect(actualValue) == expectedValue;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) != expectedValue;
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSString *", ^{
            __block NSString *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [[actualValue mutableCopy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) == expectedValue;
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue) != expectedValue;
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSString stringWithFormat:@"%d", someInteger + 1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
                            expect(actualValue) == expectedValue;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) != expectedValue;
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an NSObject *", ^{
        int someInteger = 7;
        NSObject *actualValue = [[NSString alloc] initWithFormat:@"%d", someInteger];

        describe(@"and the expected value is also declared as an NSObject *", ^{
            __block NSObject *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [[actualValue mutableCopy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) == expectedValue;
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue) != expectedValue;
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSString stringWithFormat:@"%d", someInteger + 1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
                            expect(actualValue) == expectedValue;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) != expectedValue;
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an id", ^{
            __block id expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [[actualValue mutableCopy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) == expectedValue;
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue) != expectedValue;
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSString stringWithFormat:@"%d", someInteger + 1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
                            expect(actualValue) == expectedValue;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) != expectedValue;
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSString *", ^{
            __block NSString *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [[actualValue mutableCopy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) == expectedValue;
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue) != expectedValue;
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSString stringWithFormat:@"%d", someInteger + 1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
                            expect(actualValue) == expectedValue;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) != expectedValue;
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an NSString *", ^{
        int someInteger = 7;
        NSString *actualValue = [[NSString alloc] initWithFormat:@"%d", someInteger];

        describe(@"and the expected value is declared as an NSObject *", ^{
            __block NSObject *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [[actualValue mutableCopy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) == expectedValue;
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue) != expectedValue;
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSString stringWithFormat:@"%d", someInteger + 1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
                            expect(actualValue) == expectedValue;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) != expectedValue;
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an id", ^{
            __block id expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [[actualValue mutableCopy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) == expectedValue;
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue) != expectedValue;
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSString stringWithFormat:@"%d", someInteger + 1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
                            expect(actualValue) == expectedValue;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) != expectedValue;
                    });
                });
            });
        });

        describe(@"and the expected value is also declared as an NSString *", ^{
            __block NSString *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [[actualValue mutableCopy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) == expectedValue;
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue) != expectedValue;
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSString stringWithFormat:@"%d", someInteger + 1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
                            expect(actualValue) == expectedValue;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) != expectedValue;
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as an NSNumber *", ^{
        NSNumber *actualValue = [NSNumber numberWithInt:587];

        describe(@"and the expected value is declared as an NSNumber *", ^{
            __block NSNumber *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:[actualValue intValue]];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) == expectedValue;
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <587> to not equal <587>", ^{
                            expect(actualValue) != expectedValue;
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:[actualValue intValue] + 1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <587> to equal <588>", ^{
                            expect(actualValue) == expectedValue;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) != expectedValue;
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSObject *", ^{
            __block NSObject *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:[actualValue intValue]];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) == expectedValue;
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <587> to not equal <587>", ^{
                            expect(actualValue) != expectedValue;
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:[actualValue intValue] + 1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <587> to equal <588>", ^{
                            expect(actualValue) == expectedValue;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) != expectedValue;
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSValue *", ^{
            __block NSValue *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:[actualValue intValue]];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) == expectedValue;
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible (for NSValue objects) failure message", ^{
                        expectFailureWithMessage(@"Expected <587> to not equal <587>", ^{
                            expect(actualValue) != expectedValue;
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:[actualValue intValue] + 1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible (for NSValue objects) failure message", ^{
                        expectFailureWithMessage(@"Expected <587> to equal <588>", ^{
                            expect(actualValue) == expectedValue;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) != expectedValue;
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an id", ^{
            __block id expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:[actualValue intValue]];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) == expectedValue;
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <587> to not equal <587>", ^{
                            expect(actualValue) != expectedValue;
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:[actualValue intValue] + 1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <587> to equal <588>", ^{
                            expect(actualValue) == expectedValue;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) != expectedValue;
                    });
                });
            });
        });

        describe(@"and the expected value is declared as a integer built-in type", ^{
            __block long long expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [actualValue intValue];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) == expectedValue;
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <587> to not equal <587>", ^{
                            expect(actualValue) != expectedValue;
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [actualValue intValue] + 1;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <587> to equal <588>", ^{
                            expect(actualValue) == expectedValue;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) != expectedValue;
                    });
                });
            });
        });

        describe(@"and the expected value is declared as a floating point built-in type", ^{
            __block double expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [actualValue floatValue];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) == expectedValue;
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <587> to not equal <587>", ^{
                            expect(actualValue) != expectedValue;
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [actualValue doubleValue] + 1.7;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <587> to equal <588.7>", ^{
                            expect(actualValue) == expectedValue;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualValue) != expectedValue;
                    });
                });
            });
        });
    });
});

SPEC_END
