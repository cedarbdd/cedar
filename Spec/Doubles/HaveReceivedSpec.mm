#import "Cedar.h"
#import "SimpleIncrementer.h"
#import "ExpectFailureWithMessage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;
using namespace Cedar::Doubles::Arguments;

SPEC_BEGIN(HaveReceivedSpec)

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
            expectExceptionWithReason([NSString stringWithFormat:@"Received expectation for non-double object <%@>", incrementer], ^{
                incrementer should have_received("increment");
            });
        });
    });

    context(@"with an object that is no longer being spied upon", ^{
        beforeEach(^{
            stop_spying_on(incrementer);
        });

        it(@"should raise a descriptive exception", ^{
            expectExceptionWithReason([NSString stringWithFormat:@"Received expectation for non-double object <%@>", incrementer], ^{
                incrementer should have_received("increment");
            });
        });
    });

    context(@"for a method with no parameters", ^{
        SEL method = @selector(increment);

        context(@"with a parameter expectation", ^{
            it(@"should raise an exception due to an invalid expectation", ^{
                NSString *methodString = NSStringFromSelector(method);
                NSString *reason = [NSString stringWithFormat:@"Wrong number of expected parameters for <%@>; expected: 1, actual: 0", methodString];
                ^{ expect(incrementer).to(have_received(method).with(anything)); } should raise_exception.with_reason(reason);
            });
        });

        context(@"which has been called", ^{
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
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not have received message <%@>", incrementer, NSStringFromSelector(method)], ^{
                        expect(incrementer).to_not(have_received(method));
                    });

                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not have received message <%@>", incrementer, NSStringFromSelector(method)], ^{
                        expect(incrementer).to_not(have_received("increment"));
                    });
                });
            });
        });

        context(@"which has not been called", ^{
            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to have received message <%@>", incrementer, NSStringFromSelector(method)], ^{
                        expect(incrementer).to(have_received(method));
                    });

                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to have received message <%@>", incrementer, NSStringFromSelector(method)], ^{
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

        context(@"with too few parameter expectations", ^{
            it(@"should raise an exception due to an invalid expectation", ^{
                NSString *methodName = NSStringFromSelector(@selector(incrementByABit:andABitMore:));
                NSString *reason = [NSString stringWithFormat:@"Wrong number of expected parameters for <%@>; expected: 1, actual: 2", methodName];
                ^{ expect(incrementer).to(have_received(@selector(incrementByABit:andABitMore:)).with(anything)); } should raise_exception.with_reason(reason);
            });
        });

        context(@"which has been called", ^{
            int actualParameter = 2;

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
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not have received message <%@>", incrementer, NSStringFromSelector(method)], ^{
                            expect(incrementer).to_not(have_received(method));
                        });

                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not have received message <%@>", incrementer, NSStringFromSelector(method)], ^{
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
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not have received message <%@>, with arguments: <%d>", incrementer, NSStringFromSelector(method), expectedParameter], ^{
                            expect(incrementer).to_not(have_received(method).with(expectedParameter));
                        });

                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not have received message <%@>, with arguments: <%d>", incrementer, NSStringFromSelector(method), expectedParameter], ^{
                            expect(incrementer).to_not(have_received("incrementBy:").with(expectedParameter));
                        });
                    });
                });
            });

            context(@"with an incorrect expected parameter", ^{
                unsigned short expectedParameter = actualParameter + 1;

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to have received message <%@>, with arguments: <%d> but received messages:\n"
                                                  @"  incrementBy:<2>\n"
                                                  @"  value\n"
                                                  @"  setValue:<2>\n",
                                                  incrementer, NSStringFromSelector(method), expectedParameter], ^{
                            expect(incrementer).to(have_received(method).with(expectedParameter));
                        });

                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to have received message <%@>, with arguments: <%d> but received messages:\n"
                                                  @"  incrementBy:<2>\n"
                                                  @"  value\n"
                                                  @"  setValue:<2>\n",
                                                  incrementer, NSStringFromSelector(method), expectedParameter], ^{
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
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to have received message <%@>, with arguments: <%ld>", incrementer, NSStringFromSelector(method), expectedParameter], ^{
                        expect(incrementer).to(have_received(method).with(expectedParameter));
                    });

                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to have received message <%@>, with arguments: <%ld>", incrementer, NSStringFromSelector(method), expectedParameter], ^{
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
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not have received message <%@>", incrementer, NSStringFromSelector(method)], ^{
                            expect(incrementer).to_not(have_received(method));
                        });

                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not have received message <%@>", incrementer, NSStringFromSelector(method)], ^{
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
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not have received message <%@>, with arguments: <%@>", incrementer, NSStringFromSelector(method), expectedParameter], ^{
                            expect(incrementer).to_not(have_received(method).with(expectedParameter));
                        });

                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not have received message <%@>, with arguments: <%@>", incrementer, NSStringFromSelector(method), expectedParameter], ^{
                            expect(incrementer).to_not(have_received("incrementByNumber:").with(expectedParameter));
                        });
                    });
                });
            });

            context(@"with an incorrect expected parameter", ^{
                NSNumber *expectedParameter = [NSNumber numberWithFloat:[actualParameter floatValue] + 0.5];

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to have received message <%@>, with arguments: <%@> but received messages:\n"
                                                  @"  incrementByNumber:<%@>\n"
                                                  @"  value\n"
                                                  @"  setValue:<3>\n",
                                                  incrementer, NSStringFromSelector(method),
                                                  expectedParameter, actualParameter], ^{
                            expect(incrementer).to(have_received(method).with(expectedParameter));
                        });

                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to have received message <%@>, with arguments: <%@> but received messages:\n"
                                                  @"  incrementByNumber:<%@>\n"
                                                  @"  value\n"
                                                  @"  setValue:<3>\n",
                                                  incrementer, NSStringFromSelector(method),
                                                  expectedParameter, actualParameter], ^{
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

            context(@"with an incorrect expected parameter that is nil", ^{
                context(@"that is typed as a number", ^{
                    NSNumber *expectedParameter = nil;

                    describe(@"positive match", ^{
                        it(@"should fail with a sensible failure message", ^{
                            expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to have received message <%@>, with arguments: <%@> but received messages:\n"
                                                      @"  incrementByNumber:<3>\n"
                                                      @"  value\n"
                                                      @"  setValue:<3>\n",
                                                      incrementer, NSStringFromSelector(method), expectedParameter], ^{
                                expect(incrementer).to(have_received(method).with(expectedParameter));
                            });

                            expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to have received message <%@>, with arguments: <%@> but received messages:\n"
                                                      @"  incrementByNumber:<3>\n"
                                                      @"  value\n"
                                                      @"  setValue:<3>\n",
                                                      incrementer, NSStringFromSelector(method), expectedParameter], ^{
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

                context(@"that is typed as id", ^{
                    id expectedParameter = nil;

                    describe(@"positive match", ^{
                        it(@"should fail with a sensible failure message", ^{
                            expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to have received message <%@>, with arguments: <%@> but received messages:\n"
                                                      @"  incrementByNumber:<3>\n"
                                                      @"  value\n"
                                                      @"  setValue:<3>\n",
                                                      incrementer, NSStringFromSelector(method), expectedParameter], ^{
                                expect(incrementer).to(have_received(method).with(expectedParameter));
                            });

                            expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to have received message <%@>, with arguments: <%@> but received messages:\n"
                                                      @"  incrementByNumber:<3>\n"
                                                      @"  value\n"
                                                      @"  setValue:<3>\n",
                                                      incrementer, NSStringFromSelector(method), expectedParameter], ^{
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
        });

        context(@"which has not been called", ^{
            NSNumber *expectedParameter = [NSNumber numberWithInt:2];

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to have received message <%@>, with arguments: <%@>", incrementer, NSStringFromSelector(method), expectedParameter], ^{
                        expect(incrementer).to(have_received(method).with(expectedParameter));
                    });

                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to have received message <%@>, with arguments: <%@>", incrementer, NSStringFromSelector(method), expectedParameter], ^{
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

    context(@"for a method with multiple parameters (some object, some not)", ^{
        SEL method = @selector(incrementByABit:andABitMore:);
        int actualFirstParameter = 83;
        id actualSecondParameter = [NSNumber numberWithInt:32];

        context(@"with too few parameter expectations", ^{
            it(@"should raise an exception due to an invalid expectation", ^{
                NSString *methodName = NSStringFromSelector(method);
                NSString *reason = [NSString stringWithFormat:@"Wrong number of expected parameters for <%@>; expected: 1, actual: 2", methodName];
                ^{ expect(incrementer).to(have_received(method).with(anything)); } should raise_exception.with_reason(reason);
            });
        });

        context(@"which has been called", ^{
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
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not have received message <%@>, with arguments: <%d, %@>", incrementer, NSStringFromSelector(method), expectedFirstParameter, expectedSecondParameter], ^{
                            expect(incrementer).to_not(have_received(method).with(expectedFirstParameter, expectedSecondParameter));
                        });

                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not have received message <%@>, with arguments: <%d, %@>", incrementer, NSStringFromSelector(method), expectedFirstParameter, expectedSecondParameter], ^{
                            expect(incrementer).to_not(have_received("incrementByABit:andABitMore:").with(expectedFirstParameter, expectedSecondParameter));
                        });
                    });
                });
            });

            context(@"with an incorrect parameter expectation", ^{
                unsigned long long expectedFirstParameter = actualFirstParameter;
                NSObject * expectedSecondParameter = [NSNumber numberWithFloat:[actualSecondParameter floatValue] + 0.6];

                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to have received message <%@>, with arguments: <%llu, %@> but received messages:\n"
                                                  @"  incrementByABit:andABitMore:<83, 32>\n"
                                                  @"  value\n"
                                                  @"  setValue:<115>\n",
                                                  incrementer, NSStringFromSelector(method), expectedFirstParameter, expectedSecondParameter], ^{
                            expect(incrementer).to(have_received(method).with(expectedFirstParameter, expectedSecondParameter));
                        });

                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to have received message <%@>, with arguments: <%llu, %@> but received messages:\n"
                                                  @"  incrementByABit:andABitMore:<83, 32>\n"
                                                  @"  value\n"
                                                  @"  setValue:<115>\n",
                                                  incrementer, NSStringFromSelector(method), expectedFirstParameter, expectedSecondParameter], ^{
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

        context(@"which has been called with an incorrect nil parameter", ^{
            NSObject * expectedSecondParameter = @666;

            beforeEach(^{
                [incrementer incrementByABit:actualFirstParameter andABitMore:nil];
            });

            describe(@"positive match", ^{
                it(@"should fail with a sensible error message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to have received message <%@>, with arguments: <%d, 666> but received messages:\n"
                                              @"  incrementByABit:andABitMore:<83, %@>\n"
                                              @"  value\n"
                                              @"  setValue:<83>\n",
                                              incrementer, NSStringFromSelector(method), actualFirstParameter, @"<nil>"], ^{
                        expect(incrementer).to(have_received("incrementByABit:andABitMore:").with(actualFirstParameter, expectedSecondParameter));
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    expect(incrementer).to_not(have_received(method).with(0, nil));
                    expect(incrementer).to_not(have_received("incrementByABit:andABitMore:").with(actualFirstParameter, expectedSecondParameter));
                });
            });
        });

        context(@"which has not been called", ^{
            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to have received message <%@>", incrementer, NSStringFromSelector(method)], ^{
                        expect(incrementer).to(have_received(method));
                    });

                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to have received message <%@>", incrementer, NSStringFromSelector(method)], ^{
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
