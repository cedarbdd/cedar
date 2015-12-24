#import "Cedar.h"
#import "ExpectFailureWithMessage.h"

#ifndef NS_ROOT_CLASS
#define NS_ROOT_CLASS
#endif

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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-root-class"
NS_ROOT_CLASS
@interface ClassWithoutDescriptionMethod
#pragma clang diagnostic pop
@end

@implementation ClassWithoutDescriptionMethod
+ (id)alloc {
    return NSAllocateObject(self, 0, NULL);
}

- (void)dealloc {
    NSDeallocateObject(self);
}

- (id)init {
    return self;
}

- (BOOL)isEqual:(id)other {
    return NO;
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

    describe(@"when the actual value is an id type that doesn't respond to -description", ^{
        __block id actualValue;

        beforeEach(^{
            actualValue = [[ClassWithoutDescriptionMethod alloc] init];
        });

        afterEach(^{
            [actualValue dealloc];
        });

        it(@"should properly display any failure message", ^{
            ^{ [NSString stringWithFormat:@"%p", actualValue]; }();
            expectFailureWithMessage([NSString stringWithFormat:@"Expected <ClassWithoutDescriptionMethod %p> to equal <doesntmatter>", actualValue], ^{
                actualValue should equal(@"doesntmatter");
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

            describe(@"and the values are nil", ^{
                id actualValue = nil;
                beforeEach(^{
                    expectedValue = nil;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Unexpected use of equal matcher to check for nil; use the be_nil matcher to match nil values", ^{
                            expect(actualValue).to(equal(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Unexpected use of equal matcher to check for nil; use the be_nil matcher to match nil values", ^{
                            expect(actualValue).to(equal(expectedValue));
                        });
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

            describe(@"and the values are nil", ^{
                id actualValue = nil;
                beforeEach(^{
                    expectedValue = nil;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Unexpected use of equal matcher to check for nil; use the be_nil matcher to match nil values", ^{
                            expect(actualValue).to(equal(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Unexpected use of equal matcher to check for nil; use the be_nil matcher to match nil values", ^{
                            expect(actualValue).to(equal(expectedValue));
                        });
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

        describe(@"and the expected value is declared as an NSDecimalNumber", ^{
            __block NSDecimalNumber *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"7.0"];
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
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"1.1"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to equal <1.1>", ^{
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

            describe(@"and the values are nil", ^{
                NSObject *actualValue = nil;
                beforeEach(^{
                    expectedValue = nil;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Unexpected use of equal matcher to check for nil; use the be_nil matcher to match nil values", ^{
                            expect(actualValue).to(equal(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Unexpected use of equal matcher to check for nil; use the be_nil matcher to match nil values", ^{
                            expect(actualValue).to(equal(expectedValue));
                        });
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

            describe(@"and the values are nil", ^{
                NSObject *actualValue = nil;
                beforeEach(^{
                    expectedValue = nil;
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Unexpected use of equal matcher to check for nil; use the be_nil matcher to match nil values", ^{
                            expect(actualValue).to(equal(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Unexpected use of equal matcher to check for nil; use the be_nil matcher to match nil values", ^{
                            expect(actualValue).to(equal(expectedValue));
                        });
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

        describe(@"and the expected value is declared as an NSDecimalNumber", ^{
            __block NSDecimalNumber *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"7.0"];
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
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"1.1"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to equal <1.1>", ^{
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

    describe(@"when the actual value is declared as a C string", ^{
        char *actualValue = (char *)"value";

        describe(@"and the expected value is declared as a C string", ^{
            __block char *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = (char *)calloc(strlen(actualValue) + 1, sizeof(char));
                    stpcpy(expectedValue, actualValue);
                });

                afterEach(^{
                    free(expectedValue);
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <cstring(value)> to not equal <cstring(value)>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = (char *)calloc(strlen(actualValue) + 1, sizeof(char));
                    stpcpy(expectedValue, "eulav");
                });

                afterEach(^{
                    free(expectedValue);
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expectFailureWithMessage(@"Expected <cstring(value)> to equal <cstring(eulav)>", ^{
                            expect(actualValue).to(equal(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expect(actualValue).to_not(equal(expectedValue));
                    });
                });
            });
        });

        describe(@"and the expected value is declared as a const C string", ^{
            __block const char *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = "value";
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <cstring(value)> to not equal <cstring(value)>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
                        });
                    });
                });
            });
        });
    });

    describe(@"when the actual value is declared as char array", ^{
        // char[] cannot be copied through blocks
        describe(@"and the expected value is declared as a C string", ^{
            __block char *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = (char *)"value";
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        char actualValue[] = "value";
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <cstring(value)> to not equal <cstring(value)>", ^{
                            char actualValue[] = "value";
                            expect(actualValue).to_not(equal(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the values are not equal", ^{
                beforeEach(^{
                    expectedValue = (char *)"eulav";
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expectFailureWithMessage(@"Expected <cstring(value)> to equal <cstring(eulav)>", ^{
                            char actualValue[] = "value";
                            expect(actualValue).to(equal(expectedValue));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        char actualValue[] = "value";
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

        describe(@"and the expected value is declared as an NSDecimalNumber", ^{
            __block NSDecimalNumber *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"7.0"];
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
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"1.1"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to equal <1.1>", ^{
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

                describe(@"and the expected value is nil", ^{
                    beforeEach(^{
                        expectedValue = nil;
                    });

                    describe(@"positive match", ^{
                        it(@"should fail with a sensible failure message", ^{
                            expectFailureWithMessage(@"Unexpected use of equal matcher to check for nil; use the be_nil matcher to match nil values", ^{
                                expect(actualValue).to(equal(expectedValue));
                            });
                        });
                    });

                    describe(@"negative match", ^{
                        it(@"should fail with a sensible failure message", ^{
                            expectFailureWithMessage(@"Unexpected use of equal matcher to check for nil; use the be_nil matcher to match nil values", ^{
                                expect(actualValue).to(equal(expectedValue));
                            });
                        });
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

        describe(@"and the expected value is declared as an NSDecimalNumber", ^{
            __block NSDecimalNumber *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"7.0"];
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
                    expectedValue = [NSDecimalNumber decimalNumberWithString:@"1.1"];
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <7> to equal <1.1>", ^{
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

    describe(@"when the actual value is declared as an NSDecimalNumber *", ^{
        NSDecimalNumber *actualValue = [NSDecimalNumber decimalNumberWithDecimal:[@7.f decimalValue]];

        describe(@"and the expected value is declared as an NSDecimalNumber *", ^{
            __block NSDecimalNumber *expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = [NSDecimalNumber decimalNumberWithDecimal:[actualValue decimalValue]];
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
                    expectedValue = [NSDecimalNumber decimalNumberWithDecimal:[@8 decimalValue]];
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
    });

    describe(@"when the actual value is declared as an NSDecimal", ^{
        NSDecimal actualValue = [@7.f decimalValue];

        describe(@"and the expected value is declared as an NSDecimal", ^{
            __block NSDecimal expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = actualValue;
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
                    expectedValue = [@8 decimalValue];
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
                    expectedArray = [[@[@"goodbye"] mutableCopy] autorelease];
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

    describe(@"when the actual value is declared as an NSRange", ^{
        NSRange actualValue = NSMakeRange(42, 56);

        describe(@"and the expected value is declared as an NSRange", ^{
            __block NSRange expectedValue;

            describe(@"and the values are equal", ^{
                beforeEach(^{
                    expectedValue = NSMakeRange(42, 56);
                });

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(actualValue).to(equal(expectedValue));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <{42, 56}> to not equal <{42, 56}>", ^{
                            expect(actualValue).to_not(equal(expectedValue));
                        });
                    });
                });
            });

            describe(@"and the locations are not equal", ^{
                beforeEach(^{
                    expectedValue = NSMakeRange(0, 56);
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <{42, 56}> to equal <{0, 56}>", ^{
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

            describe(@"and the lengths are not equal", ^{
                beforeEach(^{
                    expectedValue = NSMakeRange(42, 0);
                });

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <{42, 56}> to equal <{42, 0}>", ^{
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
