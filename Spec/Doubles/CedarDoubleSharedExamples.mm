#import <Cedar/SpecHelper.h>
#import "SimpleIncrementer.h"
#import "StubbedMethod.h"

SHARED_EXAMPLE_GROUPS_BEGIN(CedarDoubleSharedExamples)

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;
using namespace Cedar::Doubles::Arguments;

sharedExamplesFor(@"a Cedar double", ^(NSDictionary *sharedContext) {
    __block id<CedarDouble, SimpleIncrementer> myDouble;

    beforeEach(^{
        myDouble = [sharedContext objectForKey:@"double"];
    });

    describe(@"#stub_method", ^{
        context(@"with a non-double", ^{
            it(@"should raise an exception", ^{
                NSObject *non_double = [[[NSObject alloc] init] autorelease];
                ^{ non_double stub_method("description"); } should raise_exception.with_reason([NSString stringWithFormat:@"%@ is not a double", non_double]);
            });
        });

        context(@"with a method name that the stub does not respond to", ^{
            it(@"should raise an exception", ^{
                ^{ myDouble stub_method("wibble_wobble"); } should raise_exception;
            });
        });

        context(@"with a method with no arguments", ^{
            context(@"when stubbed twice", ^{
                it(@"should raise an exception", ^{
                    myDouble stub_method("value");
                    ^{ myDouble stub_method("value"); } should raise_exception.with_reason(@"The method <value> is already stubbed");
                });
            });

            context(@"with no return value", ^{
                beforeEach(^{
                    myDouble stub_method("value");
                });

                it(@"should record the invocation", ^{
                    [myDouble value];
                    myDouble should have_received("value");
                });

                it(@"should return zero", ^{
                    myDouble.value should equal(0);
                });
            });

            context(@"with a return value of the correct type", ^{
                size_t someArgument = 1;

                beforeEach(^{
                    myDouble stub_method("value").and_return(someArgument);
                });

                it(@"should return the specified return value", ^{
                    myDouble.value should equal(someArgument);
                });
            });

            context(@"with a return value of a type with the wrong binary size", ^{
                int someArgument = 1;

                it(@"should raise an exception", ^{
                    ^{ myDouble stub_method("value").and_return(someArgument); } should raise_exception;
                });
            });

            context(@"with a return value of an inappropriate type", ^{
                it(@"should raise an exception", ^{
                    ^{ myDouble stub_method("value").and_return(@"foo"); } should raise_exception;
                });
            });
        });

        context(@"when the stub is instructed to raise an exception", ^{
            context(@"with no parameter", ^{
                beforeEach(^{
                    myDouble stub_method("increment").and_raise_exception();
                });

                it(@"should raise a generic exception", ^{
                    ^{ [myDouble increment]; } should raise_exception([NSException class]);
                });
            });

            context(@"with a specified exception", ^{
                id someException = @"that's some pig (exception)";

                beforeEach(^{
                    myDouble stub_method("increment").and_raise_exception(someException);
                });

                it(@"should raise that exception instance", ^{
                    ^{ [myDouble increment]; } should raise_exception(someException);
                });
            });
        });

        describe(@"argument expectations", ^{
            context(@"with too few", ^{
                size_t expectedIncrementValue = 1;
                NSNumber * expectedBitMoreValue = [NSNumber numberWithInteger:10];
                NSString *reason = [NSString stringWithFormat:@"Wrong number of expected parameters for <incrementByABit:andABitMore:>; expected: 1, actual: 2"];

                it(@"should raise an exception", ^{
                    ^{ myDouble stub_method("incrementByABit:andABitMore:").with(expectedIncrementValue); } should raise_exception.with_reason(reason);
                });
            });

            context(@"with too many", ^{
                NSString *reason = [NSString stringWithFormat:@"Wrong number of expected parameters for <value>; expected: 1, actual: 0"];

                it(@"should raise an exception", ^{
                    ^{ myDouble stub_method("value").with(@"foo"); } should raise_exception.with_reason(reason);
                });
            });

            context(@"with the correct number", ^{
                context(@"of the correct types", ^{
                    size_t expectedIncrementValue = 1;
                    NSNumber *expectedBitMoreValue = [NSNumber numberWithInteger:10];
                    NSNumber *actualBitMoreValue = [NSNumber numberWithInteger:11];

                    beforeEach(^{
                        myDouble stub_method("incrementByABit:andABitMore:").with(expectedIncrementValue).and_with(expectedBitMoreValue);
                    });

                    context(@"when invoked with a parameter of the expected value", ^{
                        it(@"should not raise an exception", ^{
                            [myDouble incrementByABit:expectedIncrementValue andABitMore:expectedBitMoreValue];
                        });
                    });

                    context(@"when invoked with a parameter of the wrong value", ^{
                        it(@"should raise an exception", ^{
                            ^{ [myDouble incrementByABit:expectedIncrementValue andABitMore:actualBitMoreValue]; } should raise_exception.with_reason(@"Wrong arguments supplied to stub");
                        });
                    });
                });

                context(@"of incorrect types", ^{
                    NSArray *argumentWithInvalidEncoding = [NSArray array];
                    NSString *reason = [NSString stringWithFormat:@"Attempt to compare expected argument <%@> with actual argument type %s; argument #1 for <incrementByABit:andABitMore:>", argumentWithInvalidEncoding, @encode(size_t)];

                    it(@"should raise an exception", ^{
                        ^{ myDouble stub_method("incrementByABit:andABitMore:").with(argumentWithInvalidEncoding).and_with(@"your mom"); } should raise_exception.with_reason(reason);
                    });
                });
            });

            context(@"with a specific value", ^{
                size_t expectedValue = 1;
                size_t anotherValue = 7;

                beforeEach(^{
                    myDouble stub_method("incrementBy:").with(expectedValue);
                });

                context(@"when invoked with an argument of the expected value", ^{
                    it(@"should record the invocation", ^{
                        [myDouble incrementBy:expectedValue];
                        myDouble should have_received("incrementBy:").with(expectedValue);
                    });
                });

                context(@"when invoked with a parameter of the wrong value", ^{
                    it(@"should raise an exception", ^{
                        ^{ [myDouble incrementBy:anotherValue]; } should raise_exception.with_reason(@"Wrong arguments supplied to stub");
                    });
                });
            });

            context(@"with an arugment specified as anything", ^{
                NSNumber *expectedBitMoreValue = [NSNumber numberWithInt:777];
                NSNumber *anotherBitMoreValue = [NSNumber numberWithInt:111];

                beforeEach(^{
                    myDouble stub_method("incrementByABit:andABitMore:").with(anything).and_with(expectedBitMoreValue);
                });

                it(@"should allow any value for the 'anything' argument", ^{
                    [myDouble incrementByABit:8 andABitMore:expectedBitMoreValue];
                    [myDouble incrementByABit:88 andABitMore:expectedBitMoreValue];
                });

                it(@"should still require the non-'anything' argument to match", ^{
                    ^{ [myDouble incrementByABit:8 andABitMore:anotherBitMoreValue]; } should raise_exception.with_reason(@"Wrong arguments supplied to stub");
                });
            });
        });

        describe(@"return values", ^{
            context(@"with a value of the correct type", ^{
                size_t returnValue = 1729;

                beforeEach(^{
                    myDouble stub_method("value").and_return(returnValue);
                });

                it(@"should return the expected value", ^{
                    expect(myDouble.value).to(equal(returnValue));
                });
            });

            context(@"with a value of an incorrect type", ^{
                unsigned int invalidReturnValue = 3;

                it(@"should raise an exception", ^{
                    ^{ myDouble stub_method("value").and_return(invalidReturnValue); } should raise_exception.with_reason([NSString stringWithFormat:@"Invalid return value type (%s) for value", @encode(unsigned int)]);
                });
            });
        });
    });
});

SHARED_EXAMPLE_GROUPS_END
