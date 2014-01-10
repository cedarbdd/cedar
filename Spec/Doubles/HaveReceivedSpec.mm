#import <Cedar/SpecHelper.h>
#import "SimpleIncrementer.h"

extern "C" {
#import "ExpectFailureWithMessage.h"
}

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;
using namespace Cedar::Doubles::Arguments;

SPEC_BEGIN(HaveReceivedSpec)

NSString *expectedNonDoubleFormat = @"Received expectation for non-double object <%@>";
NSString *expectedNotHaveReceivedWithHistoryFormat = @"Expected <%@> to not have received message [%@%@], but received:\n%@";
NSString *expectedHaveReceivedWithHistoryFormat = @"Expected <%@> to have received message [%@%@], but received:\n%@";
NSString *expectedHaveReceivedWithoutHistoryFormat = @"Expected <%@> to have received message [%@%@]";
NSString *expectedArgumentsMismatchFormat = @"Wrong number of expected parameters for <%@>; expected: %d, actual: %d";

describe(@"have_received matcher", ^{
    __block SimpleIncrementer *incrementer;

    beforeEach(^{
        incrementer = [[[SimpleIncrementer alloc] init] autorelease];
        spy_on(incrementer);
    });

    context(@"with an actual value that is not a spy", ^{
        beforeEach(^{
            incrementer = [[[SimpleIncrementer alloc] init] autorelease];
        });

        it(@"should raise a descriptive exception", ^{
            expectExceptionWithReason([NSString stringWithFormat:expectedNonDoubleFormat, incrementer], ^{
                incrementer should have_received("increment");
            });
        });
    });

    context(@"with an object that is no longer being spied upon", ^{
        beforeEach(^{
            stop_spying_on(incrementer);
        });

        it(@"should raise a descriptive exception", ^{
            expectExceptionWithReason([NSString stringWithFormat:expectedNonDoubleFormat, incrementer], ^{
                incrementer should have_received("increment");
            });
        });
    });

    context(@"for a method with no parameters", ^{
        SEL method = @selector(increment);

        context(@"with a parameter expectation", ^{
            it(@"should raise an exception due to an invalid expectation", ^{
                NSString *methodString = NSStringFromSelector(method);
                NSString *reason = [NSString stringWithFormat:expectedArgumentsMismatchFormat, methodString, 1, 0];
                ^{ expect(incrementer).to(have_received(method).with(anything)); } should raise_exception.with_reason(reason);
            });
        });

        context(@"which has been called", ^{
            NSString *expectedInvocationHistory = (@" [increment]\n"
                                                   @" [value]\n"
                                                   @" [setValue:1]\n");
            beforeEach(^{
                [incrementer increment];
            });

            describe(@"positive match", ^{
                it(@"should pass", ^{
                    expect(incrementer).to(have_received(method));
                    expect(incrementer).to(have_received("increment"));
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:expectedNotHaveReceivedWithHistoryFormat, incrementer, NSStringFromSelector(method), @"", expectedInvocationHistory], ^{
                        expect(incrementer).to_not(have_received(method));
                    });

                    expectFailureWithMessage([NSString stringWithFormat:expectedNotHaveReceivedWithHistoryFormat, incrementer, NSStringFromSelector(method), @"", expectedInvocationHistory], ^{
                        expect(incrementer).to_not(have_received("increment"));
                    });
                });
            });
        });

        context(@"which has not been called", ^{
            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:expectedHaveReceivedWithoutHistoryFormat, incrementer, NSStringFromSelector(method), @""], ^{
                        expect(incrementer).to(have_received(method));
                    });

                    expectFailureWithMessage([NSString stringWithFormat:expectedHaveReceivedWithoutHistoryFormat, incrementer, NSStringFromSelector(method), @""], ^{
                        expect(incrementer).to(have_received("increment"));
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    expect(incrementer).to_not(have_received(method));
                    expect(incrementer).to_not(have_received("increment"));
                });
            });
        });

        context(@"which has not been called, but other methods were called", ^{
            NSString *expectedInvocationHistory = (@" [incrementBy:1]\n"
                                                   @" [value]\n"
                                                   @" [setValue:1]\n"
                                                   @" [incrementByNumber:2]\n"
                                                   @" [value]\n"
                                                   @" [setValue:3]\n"
                                                   @" [incrementByInteger:3]\n"
                                                   @" [value]\n"
                                                   @" [setValue:6]\n");
            beforeEach(^{
                [incrementer incrementBy:1];
                [incrementer incrementByNumber:@2];
                [incrementer incrementByInteger:3];
            });

            describe(@"positive match", ^{
                it(@"should fail with all the recorded method calls", ^{
                    expectFailureWithMessage([NSString stringWithFormat:expectedHaveReceivedWithHistoryFormat, incrementer, @"increment", @"", expectedInvocationHistory], ^{
                        expect(incrementer).to(have_received(method));
                    });

                    expectFailureWithMessage([NSString stringWithFormat:expectedHaveReceivedWithHistoryFormat, incrementer, @"increment", @"", expectedInvocationHistory], ^{
                        expect(incrementer).to(have_received("increment"));
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    expect(incrementer).to_not(have_received(method));
                    expect(incrementer).to_not(have_received("increment"));
                });
            });
        });
    });

    context(@"for a method with a non-object parameter", ^{
        SEL method = @selector(incrementBy:);

        context(@"with too many parameter expectations", ^{
            it(@"should raise an exception due to an invalid expectation", ^{
                NSString *methodName = NSStringFromSelector(method);
                NSString *reason = [NSString stringWithFormat:@"Wrong number of expected parameters for <%@>; expected: 2, actual: 1", methodName];
                ^{ expect(incrementer).to(have_received(method).with(anything, anything)); } should raise_exception.with_reason(reason);
            });
        });

        context(@"which has been called", ^{
            int actualParameter = 2;
            NSString *expectedInvocationHistory = (@" [incrementBy:2]\n"
                                                   @" [value]\n"
                                                   @" [setValue:2]\n");

            beforeEach(^{
                [incrementer incrementBy:actualParameter];
            });

            context(@"with no parameter expectations", ^{
                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(incrementer).to(have_received(method));
                        expect(incrementer).to(have_received("incrementBy:"));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:expectedNotHaveReceivedWithHistoryFormat, incrementer, NSStringFromSelector(method), @"", expectedInvocationHistory], ^{
                            expect(incrementer).to_not(have_received(method));
                        });

                        expectFailureWithMessage([NSString stringWithFormat:expectedNotHaveReceivedWithHistoryFormat, incrementer, NSStringFromSelector(method), @"", expectedInvocationHistory], ^{
                            expect(incrementer).to_not(have_received("incrementBy:"));
                        });
                    });
                });
            });

            context(@"with the correct expected parameter", ^{
                unsigned short expectedParameter = actualParameter;

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(incrementer).to(have_received(method).with(expectedParameter));
                        expect(incrementer).to(have_received("incrementBy:").with(expectedParameter));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:expectedNotHaveReceivedWithHistoryFormat, incrementer, NSStringFromSelector(method), @(expectedParameter), expectedInvocationHistory], ^{
                            expect(incrementer).to_not(have_received(method).with(expectedParameter));
                        });

                        expectFailureWithMessage([NSString stringWithFormat:expectedNotHaveReceivedWithHistoryFormat, incrementer, NSStringFromSelector(method), @(expectedParameter), expectedInvocationHistory], ^{
                            expect(incrementer).to_not(have_received("incrementBy:").with(expectedParameter));
                        });
                    });
                });
            });

            context(@"with an incorrect expected parameter", ^{
                unsigned short expectedParameter = actualParameter + 1;

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:expectedHaveReceivedWithHistoryFormat, incrementer, NSStringFromSelector(method), @(expectedParameter), expectedInvocationHistory], ^{
                            expect(incrementer).to(have_received(method).with(expectedParameter));
                        });

                        expectFailureWithMessage([NSString stringWithFormat:expectedHaveReceivedWithHistoryFormat, incrementer, NSStringFromSelector(method), @(expectedParameter), expectedInvocationHistory], ^{
                            expect(incrementer).to(have_received("incrementBy:").with(expectedParameter));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(incrementer).to_not(have_received(method).with(expectedParameter));
                        expect(incrementer).to_not(have_received("incrementBy:").with(expectedParameter));
                    });
                });
            });
        });

        context(@"which has not been called", ^{
            long expectedParameter = 3;

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:expectedHaveReceivedWithoutHistoryFormat, incrementer, NSStringFromSelector(method), @(expectedParameter)], ^{
                        expect(incrementer).to(have_received(method).with(expectedParameter));
                    });

                    expectFailureWithMessage([NSString stringWithFormat:expectedHaveReceivedWithoutHistoryFormat, incrementer, NSStringFromSelector(method), @(expectedParameter)], ^{
                        expect(incrementer).to(have_received("incrementBy:").with(expectedParameter));
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    expect(incrementer).to_not(have_received(method).with(expectedParameter));
                    expect(incrementer).to_not(have_received("incrementBy:").with(expectedParameter));
                });
            });
        });
    });

    context(@"for a method with an object parameter", ^{
        SEL method = @selector(incrementByNumber:);
        id actualParameter = [NSNumber numberWithInt:3];

        context(@"which has been called", ^{
            NSString *expectedInvocationHistory = (@" [incrementByNumber:3]\n"
                                                   @" [value]\n"
                                                   @" [setValue:3]\n");
            beforeEach(^{
                [incrementer incrementByNumber:actualParameter];
            });

            context(@"with no parameter expectations", ^{
                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(incrementer).to(have_received(method));
                        expect(incrementer).to(have_received("incrementByNumber:"));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:expectedNotHaveReceivedWithHistoryFormat, incrementer, NSStringFromSelector(method), @"", expectedInvocationHistory], ^{
                            expect(incrementer).to_not(have_received(method));
                        });

                        expectFailureWithMessage([NSString stringWithFormat:expectedNotHaveReceivedWithHistoryFormat, incrementer, NSStringFromSelector(method), @"", expectedInvocationHistory], ^{
                            expect(incrementer).to_not(have_received("incrementByNumber:"));
                        });
                    });
                });
            });

            context(@"with the correct expected parameter", ^{
                NSNumber *expectedParameter = [NSNumber numberWithFloat:[actualParameter intValue]];

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(incrementer).to(have_received(method).with(expectedParameter));
                        expect(incrementer).to(have_received("incrementByNumber:").with(expectedParameter));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:expectedNotHaveReceivedWithHistoryFormat, incrementer, NSStringFromSelector(method), expectedParameter, expectedInvocationHistory], ^{
                            expect(incrementer).to_not(have_received(method).with(expectedParameter));
                        });

                        expectFailureWithMessage([NSString stringWithFormat:expectedNotHaveReceivedWithHistoryFormat, incrementer, NSStringFromSelector(method), expectedParameter, expectedInvocationHistory], ^{
                            expect(incrementer).to_not(have_received("incrementByNumber:").with(expectedParameter));
                        });
                    });
                });
            });

            context(@"with an incorrect expected parameter", ^{
                NSNumber *expectedParameter = [NSNumber numberWithFloat:[actualParameter floatValue] + 0.5];

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:expectedHaveReceivedWithHistoryFormat, incrementer, NSStringFromSelector(method), expectedParameter, expectedInvocationHistory], ^{
                            expect(incrementer).to(have_received(method).with(expectedParameter));
                        });

                        expectFailureWithMessage([NSString stringWithFormat:expectedHaveReceivedWithHistoryFormat, incrementer, NSStringFromSelector(method), expectedParameter, expectedInvocationHistory], ^{
                            expect(incrementer).to(have_received("incrementByNumber:").with(expectedParameter));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(incrementer).to_not(have_received(method).with(expectedParameter));
                        expect(incrementer).to_not(have_received("incrementByNumber:").with(expectedParameter));
                    });
                });
            });
        });

        context(@"which has not been called", ^{
            NSNumber *expectedParameter = [NSNumber numberWithInt:2];

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:expectedHaveReceivedWithoutHistoryFormat, incrementer, NSStringFromSelector(method), expectedParameter], ^{
                        expect(incrementer).to(have_received(method).with(expectedParameter));
                    });

                    expectFailureWithMessage([NSString stringWithFormat:expectedHaveReceivedWithoutHistoryFormat, incrementer, NSStringFromSelector(method), expectedParameter], ^{
                        expect(incrementer).to(have_received("incrementByNumber:").with(expectedParameter));
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    expect(incrementer).to_not(have_received(method).with(expectedParameter));
                    expect(incrementer).to_not(have_received("incrementByNumber:").with(expectedParameter));
                });
            });
        });
    });

    context(@"for a method with multiple parameters, some object, some not", ^{
        SEL method = @selector(incrementByABit:andABitMore:);
        int actualFirstParameter = 83;
        id actualSecondParameter = [NSNumber numberWithInt:32];

        context(@"with too few parameter expectations", ^{
            it(@"should raise an exception due to an invalid expectation", ^{
                NSString *methodName = NSStringFromSelector(method);
                NSString *reason = [NSString stringWithFormat:expectedArgumentsMismatchFormat, methodName, 1, 2];
                ^{ expect(incrementer).to(have_received(method).with(anything)); } should raise_exception.with_reason(reason);
            });
        });

        context(@"which has been called", ^{
            NSString *expectedInvocationHistory = (@" [incrementByABit:83 andABitMore:32]\n"
                                                   @" [value]\n"
                                                   @" [setValue:115]\n");
            beforeEach(^{
                [incrementer incrementByABit:actualFirstParameter andABitMore:actualSecondParameter];
            });

            context(@"with the correct expected parameter", ^{
                int expectedFirstParameter = actualFirstParameter;
                NSObject * expectedSecondParameter = [NSNumber numberWithFloat:[actualSecondParameter floatValue]];

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        expect(incrementer).to(have_received(method).with(expectedFirstParameter, expectedSecondParameter));
                        expect(incrementer).to(have_received("incrementByABit:andABitMore:").with(expectedFirstParameter, expectedSecondParameter));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:expectedNotHaveReceivedWithHistoryFormat, incrementer, [NSString stringWithFormat:@"incrementByABit:%d andABitMore:%@", expectedFirstParameter, expectedSecondParameter], @"", expectedInvocationHistory], ^{
                            expect(incrementer).to_not(have_received(method).with(expectedFirstParameter, expectedSecondParameter));
                        });

                        expectFailureWithMessage([NSString stringWithFormat:expectedNotHaveReceivedWithHistoryFormat, incrementer, [NSString stringWithFormat:@"incrementByABit:%d andABitMore:%@", expectedFirstParameter, expectedSecondParameter], @"", expectedInvocationHistory], ^{
                            expect(incrementer).to_not(have_received("incrementByABit:andABitMore:").with(expectedFirstParameter, expectedSecondParameter));
                        });
                    });
                });
            });

            context(@"with an incorrect parameter expectation", ^{
                int expectedFirstParameter = actualFirstParameter;
                NSObject * expectedSecondParameter = [NSNumber numberWithFloat:[actualSecondParameter floatValue] + 0.6];

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:expectedHaveReceivedWithHistoryFormat, incrementer, [NSString stringWithFormat:@"incrementByABit:%d andABitMore:%@", expectedFirstParameter, expectedSecondParameter], @"", expectedInvocationHistory], ^{
                            expect(incrementer).to(have_received(method).with(expectedFirstParameter, expectedSecondParameter));
                        });

                        expectFailureWithMessage([NSString stringWithFormat:expectedHaveReceivedWithHistoryFormat, incrementer, [NSString stringWithFormat:@"incrementByABit:%d andABitMore:%@", expectedFirstParameter, expectedSecondParameter], @"", expectedInvocationHistory], ^{
                            expect(incrementer).to(have_received("incrementByABit:andABitMore:").with(expectedFirstParameter, expectedSecondParameter));
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        expect(incrementer).to_not(have_received(method).with(expectedFirstParameter, expectedSecondParameter));
                        expect(incrementer).to_not(have_received("incrementByABit:andABitMore:").with(expectedFirstParameter, expectedSecondParameter));
                    });
                });
            });
        });

        context(@"which has not been called", ^{
            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:expectedHaveReceivedWithoutHistoryFormat, incrementer, NSStringFromSelector(method), @""], ^{
                        expect(incrementer).to(have_received(method));
                    });

                    expectFailureWithMessage([NSString stringWithFormat:expectedHaveReceivedWithoutHistoryFormat, incrementer, NSStringFromSelector(method), @""], ^{
                        expect(incrementer).to(have_received("incrementByABit:andABitMore:"));
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    expect(incrementer).to_not(have_received(method));
                    expect(incrementer).to_not(have_received("incrementByABit:andABitMore:"));
                });
            });
        });
    });

    context(@"for a method that the object does not respond to", ^{
        SEL method = NSSelectorFromString(@"noSuchMethod:");

        it(@"should raise an exception due to an invalid expectation", ^{
            NSString *methodString = NSStringFromSelector(method);
            NSString *reason = [NSString stringWithFormat:@"Received expectation on method <%@>, which double <%@> does not respond to", methodString, incrementer];
            ^{ expect(incrementer).to(have_received(method).with(anything)); } should raise_exception.with_reason(reason);
        });

    });

    context(@"for a method that throws an exception", ^{
        it(@"should continue to record methods correctly", ^{
            @try {
                [incrementer incrementWithException];
            } @catch (NSException * ) {

            }
            [incrementer increment];

            incrementer should have_received("increment");
        });
    });
});

SPEC_END
