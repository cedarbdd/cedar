#import "Cedar.h"
#import "ExpectFailureWithMessage.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(BeNil_ARCSpec)

describe(@"be_nil matcher (under ARC)", ^{
    describe(@"when the value is a pointer to a built-in type", ^{
        __block int * value;

        describe(@"which is NULL", ^{
            beforeEach(^{
                value = NULL;
            });

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(value).to(be_nil());
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <nil> to not be nil", ^{
                        expect(value).to_not(be_nil());
                    });
                });
            });
        });

        describe(@"which is not NULL", ^{
            __block int i = 7;

            beforeEach(^{
                value = &i;
            });

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%p> to be nil", value], ^{
                        expect(value).to(be_nil());
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should should pass", ^{
                    expect(value).to_not(be_nil());
                });
            });
        });
    });

    describe(@"when the value is an id (__weak)", ^{
        __block id sValue;
        __weak __block id value;

        describe(@"which is nil", ^{
            beforeEach(^{
                value = nil;
            });

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(value).to(be_nil());
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <nil> to not be nil", ^{
                        expect(value).to_not(be_nil());
                    });
                });
            });
        });

        describe(@"which is not nil", ^{
            beforeEach(^{
                value = sValue = [NSString string];
            });

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%p> to be nil", value], ^{
                        expect(value).to(be_nil());
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should should pass", ^{
                    expect(value).to_not(be_nil());
                });
            });
        });
    });

    describe(@"when the value is an id (__strong)", ^{
        __block id value;

        describe(@"which is nil", ^{
            beforeEach(^{
                value = nil;
            });

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(value).to(be_nil());
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <nil> to not be nil", ^{
                        expect(value).to_not(be_nil());
                    });
                });
            });
        });

        describe(@"which is not nil", ^{
            beforeEach(^{
                value = [NSString string];
            });

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%p> to be nil", value], ^{
                        expect(value).to(be_nil());
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should should pass", ^{
                    expect(value).to_not(be_nil());
                });
            });
        });
    });

    describe(@"when the value is a block", ^{
        __block void(^value)(void);

        describe(@"which is nil", ^{
            beforeEach(^{
                value = nil;
            });

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(value).to(be_nil());
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <nil> to not be nil", ^{
                        expect(value).to_not(be_nil());
                    });
                });
            });
        });

        describe(@"which is not nil", ^{
            beforeEach(^{
                value = ^{};
            });

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%p> to be nil", value], ^{
                        expect(value).to(be_nil());
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should should pass", ^{
                    expect(value).to_not(be_nil());
                });
            });
        });
    });

    describe(@"when the value is not a pointer", ^{
        int value = 7;

        it(@"should fail with a sensible failure message", ^{
            expectFailureWithMessage([NSString stringWithFormat:@"Attempt to compare non-pointer type to nil"], ^{
                expect(value).to(be_nil());
            });
        });
    });
});

describe(@"be_nil shorthand syntax (no parentheses)", ^{
    void *value = NULL;

    describe(@"positive match", ^{
        it(@"should should pass", ^{
            expect(value).to(be_nil);
        });
    });

    describe(@"negative match", ^{
        it(@"should fail with a sensible failure message", ^{
            expectFailureWithMessage(@"Expected <nil> to not be nil", ^{
                expect(value).to_not(be_nil);
            });
        });
    });
});

SPEC_END
