#if TARGET_OS_IPHONE
#import <Cedar/SpecHelper.h>
#else
#import <Cedar/SpecHelper.h>
#endif

extern "C" {
#import "ExpectFailureWithMessage.h"
}

using namespace Cedar::Matchers;

@interface CustomObject : NSObject {
    BOOL shouldEqual_;
}
@property (nonatomic, assign) BOOL shouldEqual;
@end

@implementation CustomObject
@synthesize shouldEqual = shouldEqual_;
- (BOOL)isEqual:(id)object {
    return self.shouldEqual;
}
- (NSString *)description {
    return @"CustomObject";
}
@end

SPEC_BEGIN(EqualSpec)

describe(@"equal matcher", ^{
    describe(@"when the actual value is a built-in type", ^{
        int actualValue = 1;

        describe(@"and the expected value is the same built-in type", ^{
            __block int expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = 1;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <1> to not equal <1>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = 147;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <1> to equal <147>", ^{
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

        describe(@"and the expected value is a different, but comparable, built-in type", ^{
            __block float expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = 1.0;
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <1> to not equal <1>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = 0.87;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <1> to equal <0.87>", ^{
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

        describe(@"and the expected value is declared as an NSNumber", ^{
            __block NSNumber *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithFloat:1.0];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <1> to not equal <1>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithFloat:1.1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <1> to equal <1.1>", ^{
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

    describe(@"when the actual value is a char type", ^{
        char actualValue = 1;

        it(@"should properly display any failure message", ^{
            expectFailureWithMessage(@"Expected <1> to equal <63>", ^{
                char expectedValue = 63;
                expect(actualValue).to(equal(expectedValue));
            });
        });
    });

    describe(@"when the actual value is declared as an id", ^{
        int someInteger = 7;
        id actualValue = [NSNumber numberWithInt:someInteger];

        describe(@"and the expected value is declared as an NSObject *", ^{
            __block NSObject *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger + 1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
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

        describe(@"and the expected value is also declared as an id", ^{
            __block id expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger + 1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
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

        describe(@"and the expected value is declared as an NSNumber *", ^{
            __block NSNumber *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger + 1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
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

    describe(@"when the actual value is declared as an NSObject *", ^{
        int someInteger = 7;
        NSObject *actualValue = [NSNumber numberWithInt:someInteger];

        describe(@"and the expected value is also declared as an NSObject *", ^{
            __block NSObject *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger + 1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
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

        describe(@"and the expected value is declared as an id", ^{
            __block id expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger + 1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
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

        describe(@"and the expected value is declared as an NSNumber *", ^{
            __block NSNumber *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger + 1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
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
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
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

        describe(@"and the expected value is declared as an id", ^{
            __block id expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [[actualValue mutableCopy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
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

        describe(@"and the expected value is also declared as an NSString *", ^{
            __block NSString *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [[actualValue mutableCopy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
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

    describe(@"when the actual value is declared as an NSValue *", ^{
        int someInteger = 7;
        NSValue *actualValue = [NSNumber numberWithInt:someInteger];

        describe(@"and the expected value is declared as an NSObject *", ^{
            __block NSObject *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger + 1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
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

        describe(@"and the expected value is also declared as an id", ^{
            __block id expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger + 1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
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

        describe(@"and the expected value is declared as an NSNumber *", ^{
            __block NSNumber *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:someInteger + 1];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
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

    describe(@"when the actual value is declared as an NSNumber *", ^{
        int someInteger = 7;
        NSNumber *actualValue = [NSNumber numberWithInt:someInteger];

        describe(@"and the expected value is declared as an NSNumber *", ^{
            __block NSNumber *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:[actualValue intValue]];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
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
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
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

        describe(@"and the expected value is declared as an NSObject *", ^{
            __block NSObject *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:[actualValue intValue]];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
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
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
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

        describe(@"and the expected value is declared as an NSValue *", ^{
            __block NSValue *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:[actualValue intValue]];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible (for NSValue objects) failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
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
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
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

        describe(@"and the expected value is declared as an id", ^{
            __block id expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSNumber numberWithInt:[actualValue intValue]];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
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
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
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

        describe(@"and the expected value is declared as a integer built-in type", ^{
            __block long long expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [actualValue intValue];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
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
                        expectFailureWithMessage(@"Expected <7> to equal <8>", ^{
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

        describe(@"and the expected value is declared as a floating point built-in type", ^{
            __block double expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [actualValue floatValue];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to not equal <7>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
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
                        expectFailureWithMessage(@"Expected <7> to equal <8.7>", ^{
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

    describe(@"when the actual value is declared as an NSArray *", ^{
        NSString *arrayContents = @"Hello";
        NSArray *actualArray = [NSArray arrayWithObject:arrayContents];

        describe(@"and the expected value is declared as an NSObject *", ^{
            __block NSObject *expectedArray;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedArray = [[actualArray mutableCopy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualArray).to(equal(expectedArray));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <(\n    Hello\n)> to not equal <(\n    Hello\n)>", ^{
                            expect(actualArray).to_not(equal(expectedArray));
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedArray = [NSArray arrayWithObject:@"goodbye"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <(\n    Hello\n)> to equal <(\n    goodbye\n)>", ^{
                            expect(actualArray).to(equal(expectedArray));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualArray).to_not(equal(expectedArray));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an id", ^{
            __block id expectedArray;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedArray = [[actualArray mutableCopy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualArray).to(equal(expectedArray));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <(\n    Hello\n)> to not equal <(\n    Hello\n)>", ^{
                            expect(actualArray).to_not(equal(expectedArray));
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedArray = [NSArray arrayWithObject:@"goodbye"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <(\n    Hello\n)> to equal <(\n    goodbye\n)>", ^{
                            expect(actualArray).to(equal(expectedArray));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualArray).to_not(equal(expectedArray));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSArray *", ^{
            __block NSArray *expectedArray;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedArray = [[actualArray mutableCopy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualArray).to(equal(expectedArray));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <(\n    Hello\n)> to not equal <(\n    Hello\n)>", ^{
                            expect(actualArray).to_not(equal(expectedArray));
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedArray = [NSArray arrayWithObject:@"goodbye"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <(\n    Hello\n)> to equal <(\n    goodbye\n)>", ^{
                            expect(actualArray).to(equal(expectedArray));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualArray).to_not(equal(expectedArray));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as an NSMutableArray *", ^{
            __block NSMutableArray *expectedArray;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedArray = [[actualArray mutableCopy] autorelease];
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualArray).to(equal(expectedArray));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <(\n    Hello\n)> to not equal <(\n    Hello\n)>", ^{
                            expect(actualArray).to_not(equal(expectedArray));
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedArray = [NSArray arrayWithObject:@"goodbye"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <(\n    Hello\n)> to equal <(\n    goodbye\n)>", ^{
                            expect(actualArray).to(equal(expectedArray));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(actualArray).to_not(equal(expectedArray));
                    });
                });
            });
        });
    });

    describe(@"custom objects (user-defined)", ^{
        describe(@"with an actual value declared as CustomObject *", ^{
            __block CustomObject *actualObject;

            beforeEach(^{
                actualObject = [[[CustomObject alloc] init] autorelease];
            });

            describe(@"and the expected value declared as CustomObject *", ^{
                __block CustomObject *expectedObject;

                describe(@"and the values are equal", ^{
                    beforeEach(^{
                        actualObject.shouldEqual = YES;
                        expectedObject = [[[CustomObject alloc] init] autorelease];
                    });

                    describe(@"positive match", ^{
                        it(@"should pass", ^{
                            expect(actualObject).to(equal(expectedObject));
                        });
                    });

                    describe(@"negative match", ^{
                        it(@"should fail with a sensible failure message", ^{
                            expectFailureWithMessage(@"Expected <CustomObject> to not equal <CustomObject>", ^{
                                expect(actualObject).to_not(equal(expectedObject));
                            });
                        });
                    });
                });

                describe(@"and the values are not equal", ^{
                    beforeEach(^{
                        actualObject.shouldEqual = NO;
                        expectedObject = [[[CustomObject alloc] init] autorelease];
                    });

                    describe(@"positive match", ^{
                        it(@"should fail with a sensible failure message", ^{
                            expectFailureWithMessage(@"Expected <CustomObject> to equal <CustomObject>", ^{
                                expect(actualObject).to(equal(expectedObject));
                            });
                        });
                    });

                    describe(@"negative match", ^{
                        it(@"should pass", ^{
                            expect(actualObject).to_not(equal(expectedObject));
                        });
                    });
                });
            });
        });
    });
});

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-comparison"
describe(@"== operator matcher", ^{
    describe(@"when the actual value is equal to the expected value", ^{
        it(@"should pass", ^{
            expect(1) == 1;
        });
    });

    describe(@"when the actual value is not equal to the expected value", ^{
        it(@"should fail with a sensible failure message", ^{
            expectFailureWithMessage(@"Expected <1> to equal <10>", ^{
                expect(1) == 10;
            });
        });
    });

    describe(@"with and without 'to'", ^{
        int actualValue = 1, expectedValue = 1;

        describe(@"positive match", ^{
            it(@"should pass", ^{
                expect(actualValue) == expectedValue;
                expect(actualValue).to == expectedValue;
            });
        });

        describe(@"negative match", ^{
            it(@"should fail with a sensible failure message", ^{
                expectFailureWithMessage(@"Expected <1> to not equal <1>", ^{
                    expect(actualValue).to_not == expectedValue;
                });
            });
        });
    });
});

describe(@"!= operator matcher", ^{
    describe(@"when the actual value is equal to the expected value", ^{
        it(@"should fail with a sensible failure message", ^{
            expectFailureWithMessage(@"Expected <1> to not equal <1>", ^{
                expect(1) != 1;
            });
        });
    });

    describe(@"when the actual value is not equal to the expected value", ^{
        it(@"should pass", ^{
            expect(1) != 10;
        });
    });

    describe(@"with and without 'to'", ^{
        int actualValue = 1, expectedValue = 10;

        describe(@"positive match", ^{
            it(@"should pass", ^{
                expect(actualValue) != expectedValue;
                expect(actualValue).to != expectedValue;
            });
        });

        describe(@"negative match", ^{
            it(@"should fail with a sensible failure message (despite the double negative)", ^{
                expectFailureWithMessage(@"Expected <1> to equal <10>", ^{
                    expect(actualValue).to_not != expectedValue;
                });
            });
        });
    });
});
#pragma clang diagnostic pop

SPEC_END
