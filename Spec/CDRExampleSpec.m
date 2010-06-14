#import <Cedar/SpecHelper.h>
#import <OCMock/OCMock.h>
#import "CDRExample.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

SPEC_BEGIN(CDRExampleSpec)

describe(@"CDRExample", ^{
    __block CDRExample *example;

    beforeEach(^{
        example = [[CDRExample alloc] initWithText:@"I should pass" andBlock:^{}];
    });

    afterEach(^{
        [example release];
    });

    describe(@"state", ^{
        describe(@"for a newly created example", ^{
            it(@"should be CDRExampleStateIncomplete", ^{
                assertThatInt([example state], equalToInt(CDRExampleStateIncomplete));
            });
        });

        describe(@"for an example that has run and succeeded", ^{
            beforeEach(^{
                [example runWithRunner:nil];
            });

            it(@"should be CDRExampleStatePassed", ^{
                assertThatInt([example state], equalToInt(CDRExampleStatePassed));
            });
        });

        describe(@"for an example that has run and failed", ^{
            beforeEach(^{
                [example release];
                example = [[CDRExample alloc] initWithText:@"I should fail" andBlock:^{ fail(@"fail"); }];
                [example runWithRunner:nil];
            });

            it(@"should be CDRExampleStateFailed", ^{
                assertThatInt([example state], equalToInt(CDRExampleStateFailed));
            });
        });

        describe(@"for an example that has run and thrown an NSException", ^{
            beforeEach(^{
                [example release];
                example = [[CDRExample alloc] initWithText:@"I should throw an NSException" andBlock:^{ [[NSException exceptionWithName:@"name" reason:@"reason" userInfo:nil] raise]; }];
                [example runWithRunner:nil];
            });

            it(@"should be CDRExceptionStateError", ^{
                assertThatInt([example state], equalToInt(CDRExampleStateError));
            });
        });

        describe(@"for an example that has run and thrown something other than an NSException", ^{
            beforeEach(^{
                [example release];
                example = [[CDRExample alloc] initWithText:@"I should throw some nonsense" andBlock:^{ @throw @"Some nonsense"; }];
                [example runWithRunner:nil];
            });

            it(@"should be CDRExceptionStateError", ^{
                assertThatInt([example state], equalToInt(CDRExampleStateError));
            });
        });

        describe(@"for a pending example", ^{
            beforeEach(^{
                [example release];
                example = [[CDRExample alloc] initWithText:@"I should be pending" andBlock:PENDING];
                [example runWithRunner:nil];
            });

            it(@"should be CDRExceptionStatePending", ^{
                assertThatInt([example state], equalToInt(CDRExampleStatePending));
            });
        });

        describe(@"KVO", ^{
            it(@"should report when the state changes", ^{
                id mockObserver = [OCMockObject niceMockForClass:[NSObject class]];
                [[mockObserver expect] observeValueForKeyPath:@"state" ofObject:example change:[OCMArg any] context:NULL];

                [example addObserver:mockObserver forKeyPath:@"state" options:0 context:NULL];
                [example runWithRunner:nil];
                [example removeObserver:mockObserver forKeyPath:@"state"];

                [mockObserver verify];
            });
        });
    });
});

SPEC_END
