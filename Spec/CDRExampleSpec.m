#define HC_SHORTHAND
#if TARGET_OS_IPHONE
// Normally you would include this file out of the framework.  However, we're
// testing the framework here, so including the file from the framework will
// conflict with the compiler attempting to include the file from the project.
#import "SpecHelper.h"
#import <OCMock-iPhone/OCMock.h>
#import <OCHamcrest-iPhone/OCHamcrest.h>
#else
#import <Cedar/SpecHelper.h>
#import <OCMock/OCMock.h>
#import <OCHamcrest/OCHamcrest.h>
#endif

#import "CDRExample.h"
#import "CDRExampleGroup.h"

SPEC_BEGIN(CDRExampleSpec)

describe(@"CDRExample", ^{
    __block CDRExample *example;
    NSString *exampleText = @"Example!";

    beforeEach(^{
        example = [[CDRExample alloc] initWithText:exampleText andBlock:^{}];
    });

    afterEach(^{
        [example release];
    });

    describe(@"hasChildren", ^{
        it(@"should return false", ^{
            assertThatBool([example hasChildren], equalToBool(NO));
        });
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

    describe(@"progress", ^{
        describe(@"when the state is incomplete", ^{
            beforeEach(^{
                assertThatInt([example state], equalToInt(CDRExampleStateIncomplete));
            });

            it(@"should return 0", ^{
                assertThatFloat([example progress], equalToFloat(0.0));
            });
        });
        describe(@"when the state is passed", ^{
            beforeEach(^{
                [example runWithRunner:nil];
                assertThatInt([example state], equalToInt(CDRExampleStatePassed));
            });

            it(@"should return 1", ^{
                assertThatFloat([example progress], equalToFloat(1.0));
            });
        });
    });

    describe(@"fullText", ^{
        describe(@"with no parent", ^{
            beforeEach(^{
                assertThat([example parent], nilValue());
            });

            it(@"should return just its own text", ^{
                assertThat([example fullText], equalTo(exampleText));
            });
        });

        describe(@"with a parent", ^{
            __block CDRExampleGroup *group;
            NSString *groupText = @"Parent!";

            beforeEach(^{
                group = [[CDRExampleGroup alloc] initWithText:groupText];
                [group add:example];
                assertThat([example parent], isNot(nilValue()));
            });

            afterEach(^{
                [group release];
            });

            it(@"should return its parent's text pre-pended with its own text", ^{
                assertThat([example fullText], equalTo([NSString stringWithFormat:@"%@ %@", groupText, exampleText]));
            });

            describe(@"when the parent also has a parent", ^{
                __block CDRExampleGroup *rootGroup;
                NSString *rootGroupText = @"Root!";

                beforeEach(^{
                    rootGroup = [[CDRExampleGroup alloc] initWithText:rootGroupText];
                    [rootGroup add:group];
                });

                afterEach(^{
                    [rootGroup release];
                });

                it(@"should include the text from all parents, pre-pended in the appopriate order", ^{
                    assertThat([example fullText], equalTo([NSString stringWithFormat:@"%@ %@ %@", rootGroupText, groupText, exampleText]));
                });
            });
        });
    });
});

SPEC_END
