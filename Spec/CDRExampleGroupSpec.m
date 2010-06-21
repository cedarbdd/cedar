#import <Cedar/SpecHelper.h>
#import <OCMock/OCMock.h>
#import "CDRExampleGroup.h"
#import "CDRExample.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

SPEC_BEGIN(CDRExampleGroupSpec)

describe(@"CDRExampleGroup", ^{
    __block CDRExampleGroup *group;
    __block CDRExample *incompleteExample, *pendingExample, *passingExample, *failingExample, *errorExample;

    beforeEach(^{
        group = [[CDRExampleGroup alloc] initWithText:@"a group"];
        incompleteExample = [[CDRExample alloc] initWithText:@"incomplete" andBlock:^{}];
        passingExample = [[CDRExample alloc] initWithText:@"I should pass" andBlock:^{}];
        failingExample = [[CDRExample alloc] initWithText:@"I should fail" andBlock:^{fail(@"I have failed.");}];
        pendingExample = [[CDRExample alloc] initWithText:@"I should pend" andBlock:nil];
        errorExample = [[CDRExample alloc] initWithText:@"I should raise an error" andBlock:^{ @throw @"wibble"; }];
    });

    afterEach(^{
        [errorExample release];
        [pendingExample release];
        [failingExample release];
        [passingExample release];
        [incompleteExample release];
        [group release];
    });

    describe(@"state", ^{
        describe(@"for a group containing no examples", ^{
            beforeEach(^{
                assertThatInt([[group examples] count], equalToInt(0));
            });

            it(@"should be CDRExampleStatePassed", ^{
                assertThatInt([group state], equalToInt(CDRExampleStatePassed));
            });
        });

        describe(@"for a group containing at least one incomplete example", ^{
            beforeEach(^{
                [group add:incompleteExample];
            });

            it(@"should be CDRExampleStateIncomplete", ^{
                assertThatInt([group state], equalToInt(CDRExampleStateIncomplete));
            });
        });

        describe(@"for a group containing only complete examples", ^{
            describe(@"with only passing examples", ^{
                beforeEach(^{
                    [group add:passingExample];
                    [group runWithRunner:nil];
                });

                it(@"should be CDRExampleStatePassed", ^{
                    assertThatInt([group state], equalToInt(CDRExampleStatePassed));
                });
            });

            describe(@"with only failing examples", ^{
                beforeEach(^{
                    [group add:failingExample];
                    [group runWithRunner:nil];
                });

                it(@"should be CDRExampleStateFailed", ^{
                    assertThatInt([group state], equalToInt(CDRExampleStateFailed));
                });
            });

            describe(@"with only pending examples", ^{
                beforeEach(^{
                    [group add:pendingExample];
                    [group runWithRunner:nil];
                });

                it(@"should be CDRExampleStatePending", ^{
                    assertThatInt([group state], equalToInt(CDRExampleStatePending));
                });
            });

            describe(@"with only error examples", ^{
                beforeEach(^{
                    [group add:errorExample];
                    [group runWithRunner:nil];
                });

                it(@"should be CDRExampleStateError", ^{
                    assertThatInt([group state], equalToInt(CDRExampleStateError));
                });
            });

            describe(@"with at least one failing example", ^{
                beforeEach(^{
                    [group add:failingExample];
                });

                describe(@"with all other examples passing", ^{
                    beforeEach(^{
                        [group add:passingExample];
                        [group runWithRunner:nil];
                    });

                    it(@"should be CDRExampleStateFailed", ^{
                        assertThatInt([group state], equalToInt(CDRExampleStateFailed));
                    });
                });

                describe(@"with at least one pending example", ^{
                    beforeEach(^{
                        [group add:pendingExample];
                        [group runWithRunner:nil];
                    });

                    it(@"should be CDRExampleStateFailed", ^{
                        assertThatInt([group state], equalToInt(CDRExampleStateFailed));
                    });
                });
            });

            describe(@"with at least one error example", ^{
                beforeEach(^{
                    [group add:errorExample];
                });

                describe(@"with all other examples passing", ^{
                    beforeEach(^{
                        [group add:passingExample];
                        [group runWithRunner:nil];
                    });

                    it(@"should be CDRExampleStateError", ^{
                        assertThatInt([group state], equalToInt(CDRExampleStateError));
                    });
                });

                describe(@"with at least one failing example", ^{
                    beforeEach(^{
                        [group add:failingExample];
                        [group runWithRunner:nil];
                    });

                    it(@"should be CDRExampleStateError", ^{
                        assertThatInt([group state], equalToInt(CDRExampleStateError));
                    });
                });

                describe(@"with at least one pending example", ^{
                    beforeEach(^{
                        [group add:pendingExample];
                        [group runWithRunner:nil];
                    });

                    it(@"should be CDRExampleStateError", ^{
                        assertThatInt([group state], equalToInt(CDRExampleStateError));
                    });
                });
            });

            describe(@"with at least one pending example", ^{
                beforeEach(^{
                    [group add:pendingExample];
                });

                describe(@"with all other examples passing", ^{
                    beforeEach(^{
                        [group add:passingExample];
                        [group runWithRunner:nil];
                    });

                    it(@"should be CDRExampleStatePending", ^{
                        assertThatInt([group state], equalToInt(CDRExampleStatePending));
                    });
                });
            });
        });

        describe(@"KVO", ^{
            __block id mockObserver;

            describe(@"when a child changes state, causing the group to change state", ^{
                __block CDRExample *example;

                beforeEach(^{
                    [group add:passingExample];

                    mockObserver = [OCMockObject niceMockForClass:[NSObject class]];
                    [[mockObserver expect] observeValueForKeyPath:@"state" ofObject:group change:[OCMArg any] context:NULL];
                });

                it(@"should report that the state has changed", ^{
                    [group addObserver:mockObserver forKeyPath:@"state" options:0 context:NULL];
                    [passingExample runWithRunner:nil];
                    [group removeObserver:mockObserver forKeyPath:@"state"];

                    [mockObserver verify];
                });
            });

            describe(@"when a child's child changes state, causing the child group to change state, causing the top-level group to change state", ^{
                __block CDRExampleGroup *subgroup;
                __block CDRExample *example;

                beforeEach(^{
                    subgroup = [[CDRExampleGroup alloc] initWithText:@"subgroup"];
                    [group add:subgroup];
                    [subgroup release];

                    [subgroup add:passingExample];

                    mockObserver = [OCMockObject niceMockForClass:[NSObject class]];
                    [[mockObserver expect] observeValueForKeyPath:@"state" ofObject:group change:[OCMArg any] context:NULL];
                });

                it(@"should report that the state has changed", ^{
                    [group addObserver:mockObserver forKeyPath:@"state" options:0 context:NULL];
                    [passingExample runWithRunner:nil];
                    [group removeObserver:mockObserver forKeyPath:@"state"];

                    [mockObserver verify];
                });
            });

            describe(@"when a child example changes state, but the group state does not change", ^{
                beforeEach(^{
                    [group add:failingExample];
                    [failingExample runWithRunner:nil];

                    [group add:passingExample];
                    assertThatInt([group state], equalToInt(CDRExampleStateFailed));

                    mockObserver = [OCMockObject mockForClass:[NSObject class]];
                    [[[mockObserver stub] andThrow:[NSException exceptionWithName:@"name" reason:@"reason" userInfo:nil]] observeValueForKeyPath:@"state" ofObject:group change:[OCMArg any] context:NULL];
                });

                it(@"should not report that the state has changed", ^{
                    [passingExample runWithRunner:nil];
                    assertThatInt([group state], equalToInt(CDRExampleStateFailed));
                });
            });
        });
    });

    describe(@"progress", ^{
        describe(@"when the group is empty", ^{
            beforeEach(^{
                assertThatInt([group.examples count], equalToInt(0));
            });

            it(@"should be equal to 1", ^{
                assertThatFloat([group progress], equalToFloat(1.0));
            });
        });

        describe(@"when the group contains all incomplete children", ^{
            beforeEach(^{
                [group add:incompleteExample];
            });

            it(@"should be equal to 0", ^{
                assertThatFloat([group progress], equalToFloat(0.0));
            });
        });

        describe(@"when the group contains all complete children", ^{
            beforeEach(^{
                [group add:passingExample];
                [passingExample runWithRunner:nil];
            });

            it(@"should be equal to 1", ^{
                assertThatFloat([group progress], equalToFloat(1.0));
            });
        });

        describe(@"when the group contains a mix of incomplete and complete children", ^{
            beforeEach(^{
                [group add:incompleteExample];
                [group add:passingExample];
                [passingExample runWithRunner:nil];
                [group add:failingExample];
                [failingExample runWithRunner:nil];
            });

            it(@"should be the mean of the progress of each child", ^{
                assertThatFloat([group progress], equalToFloat(2.0 / 3.0));
            });
        });
    });
});

SPEC_END
