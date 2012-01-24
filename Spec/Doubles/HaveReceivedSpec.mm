#import <Cedar/SpecHelper.h>
#import "SimpleIncrementer.h"

extern "C" {
#import "ExpectFailureWithMessage.h"
}

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HaveReceivedSpec)

describe(@"have_received matcher", ^{
    __block SimpleIncrementer *incrementer;

    beforeEach(^{
        incrementer = [[[SimpleIncrementer alloc] init] autorelease];
        spy_on(incrementer);
    });

    context(@"with an actual value that is not a spy", ^{
        it(@"should raise a descriptive exception", PENDING);
    });

    context(@"for a method with no parameters", ^{
        SEL method = @selector(increment);

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
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to have received message <%@>, with arguments: <%d>", incrementer, NSStringFromSelector(method), expectedParameter], ^{
                            expect(incrementer).to(have_received(method).with(expectedParameter));
                        });

                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to have received message <%@>, with arguments: <%d>", incrementer, NSStringFromSelector(method), expectedParameter], ^{
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
            it(@"should write this spec", PENDING);
        });
    });

    context(@"for a method with an object parameter", ^{
        SEL method = @selector(incrementByNumber:);

        context(@"which has been called", ^{
            context(@"with no parameter expectations", ^{
                describe(@"positive match", ^{
                    it(@"should pass", ^{
//                        expect(incrementer).to(have_received(method));
//                        expect(incrementer).to(have_received("incrementBy:"));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
//                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not have received message <%@>", incrementer, NSStringFromSelector(method)], ^{
//                            expect(incrementer).to_not(have_received(method));
//                        });
//
//                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not have received message <%@>", incrementer, NSStringFromSelector(method)], ^{
//                            expect(incrementer).to_not(have_received("incrementBy:"));
//                        });
                    });
                });
            });

            context(@"with the correct expected parameter", ^{
                describe(@"positive match", ^{
                    it(@"should pass", ^{
//                        expect(incrementer).to(have_received(method).with(2));
//                        expect(incrementer).to(have_received("incrementBy:").with(2));
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
//                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not have received message <%@>, with arguments: <2>", incrementer, NSStringFromSelector(method)], ^{
//                            expect(incrementer).to_not(have_received(method).with(2));
//                        });
//
//                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not have received message <%@>, with arguments: <2>", incrementer, NSStringFromSelector(method)], ^{
//                            expect(incrementer).to_not(have_received("incrementBy:").with(2));
//                        });
                    });
                });
            });

            context(@"with an incorrect expected parameter", ^{
                it(@"should write this spec", PENDING);
            });
        });

        context(@"which has not been called", ^{
            it(@"should write this spec", PENDING);
        });
    });

    context(@"for a method with multiple parameters, some object, some not", ^{
        SEL method = @selector(incrementBySomething:orOther:);

        context(@"which has been called", ^{
            context(@"with some correct parameters and some missing parameters", ^{
                it(@"should write these specs", PENDING);
            });
            
            context(@"with some incorrect parameters and some missing parameters", ^{
                it(@"should write these specs", PENDING);
            });
        });

        context(@"which has not been called", ^{
            it(@"should write this spec", PENDING);
        });
    });
    
    context(@"for a method that throws an exception", ^{
        it(@"should continue to record methods correctly", PENDING);
    });
});

SPEC_END
