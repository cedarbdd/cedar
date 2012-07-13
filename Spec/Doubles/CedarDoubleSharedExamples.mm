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
        context(@"with a method name that the stub does not respond to", ^{
            it(@"should raise an exception", ^{
                ^{ [myDouble stub_method]("wibble_wobble"); } should raise_exception;
            });
        });

        context(@"with a method with no parameters", ^{
            __block Cedar::Doubles::StubbedMethod *stubbed_method_ptr;

            beforeEach(^{
                // This should work.  Thanks for the compiler bug, Apple.
                // Radar #???
                // myDouble.stub_method("value");
                stubbed_method_ptr = &[myDouble stub_method]("value");
            });

            it(@"should record the invocation", ^{
                [myDouble value];
                myDouble should have_received("value");
            });

            context(@"and then stubbed again", ^{
                it(@"should raise an exception", ^{
                    ^{ [myDouble stub_method]("value"); } should raise_exception;
                });
            });

            context(@"with no return value", ^{
                it(@"should return zero", ^{
                    myDouble.value should equal(0);
                });
            });

            context(@"with a return value of the correct type", ^{
                size_t someArgument = 1;

                beforeEach(^{
                    stubbed_method_ptr->and_return(someArgument);
                });

                it(@"should return the specified return value", ^{
                    myDouble.value should equal(someArgument);
                });
            });

            context(@"with a return value of a type with the wrong binary size", ^{
                int someArgument = 1;

                it(@"should raise an exception", ^{
                    ^{ stubbed_method_ptr->and_return(someArgument); } should raise_exception;
                });
            });

            context(@"with a return value of an inappropriate type", ^{
                it(@"should raise an exception", ^{
                    ^{ stubbed_method_ptr->and_return(@"foo"); } should raise_exception;
                });
            });

            context(@"with too many argument expectations", ^{
                beforeEach(^{
                    stubbed_method_ptr->with(@"foo");
                });

                it(@"should raise an exception", ^{
                    NSString *reason = [NSString stringWithFormat:@"Wrong number of expected parameters for <value>; expected: 1, actual: 0"];
                    ^{ [myDouble value]; } should raise_exception.with_reason(reason);
                });
            });
        });

        context(@"with a method that takes a single parameter", ^{
            __block Cedar::Doubles::StubbedMethod *stubbed_method_ptr;
            size_t expectedValue = 1;
            size_t actualValue = 6;

            beforeEach(^{
                stubbed_method_ptr = &[myDouble stub_method]("incrementBy:");
            });

            context(@"when invoked with a parameter of the expected value", ^{
                it(@"should not raise an exception", ^{
                    [myDouble incrementBy:expectedValue];
                });
            });

            context(@"with a specific expected argument", ^{
                beforeEach(^{
                    stubbed_method_ptr->with(expectedValue);
                });

                context(@"when invoked with a parameter of the expected value", ^{
                    it(@"should not raise an exception", ^{
                        [myDouble incrementBy:expectedValue];
                    });
                });

                context(@"when invoked with a parameter of the wrong value", ^{
                    it(@"should raise an exception", ^{
                        ^{ [myDouble incrementBy:actualValue]; } should raise_exception;
                    });
                });
            });

            context(@"with any value", ^{
                beforeEach(^{
                    stubbed_method_ptr->with(anything);
                });

                it(@"should not raise an exception", ^{
                    [myDouble incrementBy:actualValue];
                });
            });
        });

        context(@"with a method that takes multiple parameters", ^{
            size_t expectedIncrementValue = 1;
            NSNumber * expectedBitMoreValue = [NSNumber numberWithInteger:10];
            NSNumber * actualBitMoreValue = [NSNumber numberWithInteger:60];

            context(@"with the correct number of argument expectations", ^{
                context(@"of the correct types", ^{
                    beforeEach(^{
                        [myDouble stub_method]("incrementByABit:andABitMore:").with(expectedIncrementValue).and_with(expectedBitMoreValue);
                    });

                    context(@"when invoked with a parameter of the expected value", ^{
                        it(@"should not raise an exception", ^{
                            [myDouble incrementByABit:expectedIncrementValue andABitMore:expectedBitMoreValue];
                        });
                    });

                    context(@"when invoked with a parameter of the wrong value", ^{
                        it(@"should raise an exception", ^{
                            ^{ [myDouble incrementByABit:expectedIncrementValue andABitMore:actualBitMoreValue]; } should raise_exception;
                        });
                    });
                });

                context(@"of incorrect types", ^{
                    NSArray *argumentWithInvalidEncoding = [NSArray array];

                    beforeEach(^{
                        [myDouble stub_method]("incrementByABit:andABitMore:").with(argumentWithInvalidEncoding).and_with(@"your mom");
                    });

                    it(@"should raise an exception", ^{
                        NSString *reason = [NSString stringWithFormat:@"Attempt to compare expected argument <%@> with actual argument type %s; argument #1 for <incrementByABit:andABitMore:>", argumentWithInvalidEncoding, @encode(size_t)];
                        ^{ [myDouble incrementByABit:expectedIncrementValue andABitMore:actualBitMoreValue]; } should raise_exception.with_reason(reason);
                    });
                });
            });

            context(@"with too few expected arguments", ^{
                beforeEach(^{
                    [myDouble stub_method]("incrementByABit:andABitMore:").with(expectedIncrementValue);
                });

                it(@"should raise an exception", ^{
                    NSString *reason = [NSString stringWithFormat:@"Wrong number of expected parameters for <incrementByABit:andABitMore:>; expected: 1, actual: 2"];
                    ^{ [myDouble incrementByABit:expectedIncrementValue andABitMore:expectedBitMoreValue]; } should raise_exception.with_reason(reason);
                });
            });
        });

        context(@"when the stub is instructed to raise an exception", ^{
            context(@"with no parameter", ^{
                beforeEach(^{
                    [myDouble stub_method]("increment").and_raise_exception();
                });

                it(@"should raise a generic exception", ^{
                    ^{ [myDouble increment]; } should raise_exception([NSException class]);
                });
            });

            context(@"with a specified exception", ^{
                id someException = @"that's some pig (exception)";

                beforeEach(^{
                    [myDouble stub_method]("increment").and_raise_exception(someException);
                });

                it(@"should raise that exception instance", ^{
                    ^{ [myDouble increment]; } should raise_exception(someException);
                });
            });
        });
    });
});

SHARED_EXAMPLE_GROUPS_END
