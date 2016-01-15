#import "Cedar.h"
#import "ExpectFailureWithMessage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(BeFalsySpec)

describe(@"be_falsy matcher", ^{
    describe(@"when the value is a built-in type", ^{
        __block BOOL value;

        describe(@"which evaluates to false", ^{
            beforeEach(^{
                value = NO;
            });

            describe(@"positive match", ^{
                it(@"should pass", ^{
                    value should be_falsy;
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <NO> to not evaluate to false", ^{
                        value should_not be_falsy;
                    });
                });
            });
        });

        describe(@"which evaluates to true", ^{
            beforeEach(^{
                value = YES;
            });

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <YES> to evaluate to false", ^{
                        value should be_falsy;
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should should pass", ^{
                    value should_not be_falsy;
                });
            });
        });
    });

    describe(@"when the value is an id", ^{
        __block id value;

        describe(@"which evaluates to false", ^{
            beforeEach(^{
                value = nil;
            });

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    value should be_falsy;
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <(null)> to not evaluate to false", ^{
                        value should_not be_falsy;
                    });
                });
            });
        });

        describe(@"which evaluates to true", ^{
            beforeEach(^{
                value = @"cat";
            });

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <cat> to evaluate to false", ^{
                        value should be_falsy;
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should should pass", ^{
                    value should_not be_falsy;
                });
            });
        });
    });
});

SPEC_END
