#import "Cedar.h"
#import "ExpectFailureWithMessage.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(BeTruthySpec)

describe(@"be_truthy matcher", ^{
    describe(@"when the value is a built-in type", ^{
        __block BOOL value;

        describe(@"which evaluates to true", ^{
            beforeEach(^{
                value = YES;
            });

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(value).to(be_truthy());
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <YES> to not evaluate to true", ^{
                        expect(value).to_not(be_truthy());
                    });
                });
            });
        });

        describe(@"which evaluates to false", ^{
            beforeEach(^{
                value = NO;
            });

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <NO> to evaluate to true", ^{
                        expect(value).to(be_truthy());
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should should pass", ^{
                    expect(value).to_not(be_truthy());
                });
            });
        });
    });

    describe(@"when the value is an id", ^{
        __block id value;

        describe(@"which evaluates to true", ^{
            beforeEach(^{
                value = @"wibble";
            });

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(value).to(be_truthy());
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <wibble> to not evaluate to true", ^{
                        expect(value).to_not(be_truthy());
                    });
                });
            });
        });

        describe(@"which evaluates to false", ^{
            beforeEach(^{
                value = nil;
            });

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <(null)> to evaluate to true", ^{
                        expect(value).to(be_truthy());
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should should pass", ^{
                    expect(value).to_not(be_truthy());
                });
            });
        });
    });
});

describe(@"be_truthy shorthand syntax (no parentheses)", ^{
    BOOL value = YES;

    describe(@"positive match", ^{
        it(@"should should pass", ^{
            expect(value).to(be_truthy);
        });
    });

    describe(@"negative match", ^{
        it(@"should fail with a sensible failure message", ^{
            expectFailureWithMessage(@"Expected <YES> to not evaluate to true", ^{
                expect(value).to_not(be_truthy);
            });
        });
    });
});

SPEC_END
