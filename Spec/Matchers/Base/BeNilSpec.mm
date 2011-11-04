#if TARGET_OS_IPHONE
#import <Cedar/SpecHelper.h>
#import "OCMock.h"
#else
#import <Cedar/SpecHelper.h>
#import <OCMock/OCMock.h>
#endif

extern "C" {
#import "ExpectFailureWithMessage.h"
}

using namespace Cedar::Matchers;

SPEC_BEGIN(BeNilSpec)

describe(@"be_nil matcher", ^{
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
                    expectFailureWithMessage(@"Expected <0> to not be nil", ^{
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
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%x> to be nil", value], ^{
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

    describe(@"when the value is an id", ^{
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
                    expectFailureWithMessage(@"Expected <0> to not be nil", ^{
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
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%x> to be nil", value], ^{
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

describe(@"be_nil shorthand syntax (no parenthesis)", ^{
    void *value = NULL;

    describe(@"positive match", ^{
        it(@"should should pass", ^{
            expect(value).to(be_nil);
        });
    });

    describe(@"negative match", ^{
        it(@"should fail with a sensible failure message", ^{
            expectFailureWithMessage(@"Expected <0> to not be nil", ^{
                expect(value).to_not(be_nil);
            });
        });
    });
});

SPEC_END
