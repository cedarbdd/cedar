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

#import "CDRExampleBase.h"
#import "CDRExampleGroup.h"
#import "CDRExample.h"

SPEC_BEGIN(CDRExampleGroupSpec)

describe(@"CDRExampleGroup", ^{
    __block CDRExampleGroup *group;
    __block CDRExample *incompleteExample, *pendingExample, *passingExample, *failingExample, *errorExample;
    NSString *groupText = @"Group!";

    beforeEach(^{
        group = [[CDRExampleGroup alloc] initWithText:groupText];
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

    describe(@"hasChildren", ^{
        beforeEach(^{
            assertThatInt([[group examples] count], equalToInt(0));
        });

        describe(@"for an empty group", ^{
            it(@"should return false", ^{
                assertThatBool([group hasChildren], equalToBool(NO));
            });
        });

        describe(@"for a non-empty group", ^{
            beforeEach(^{
                [group add:incompleteExample];
                assertThatInt([[group examples] count], isNot(equalToInt(0)));
            });

            it(@"should return true", ^{
                assertThatBool([group hasChildren], equalToBool(YES));
            });
        });
    });

    describe(@"state", ^{
        describe(@"for a group containing no examples", ^{
            beforeEach(^{
                assertThatInt([[group examples] count], equalToInt(0));
            });

            it(@"should be CDRExampleStatePending", ^{
                assertThatInt([group state], equalToInt(CDRExampleStatePending));
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
                    [group run];
                });

                it(@"should be CDRExampleStatePassed", ^{
                    assertThatInt([group state], equalToInt(CDRExampleStatePassed));
                });
            });

            describe(@"with only failing examples", ^{
                beforeEach(^{
                    [group add:failingExample];
                    [group run];
                });

                it(@"should be CDRExampleStateFailed", ^{
                    assertThatInt([group state], equalToInt(CDRExampleStateFailed));
                });
            });

            describe(@"with only pending examples", ^{
                beforeEach(^{
                    [group add:pendingExample];
                    [group run];
                });

                it(@"should be CDRExampleStatePending", ^{
                    assertThatInt([group state], equalToInt(CDRExampleStatePending));
                });
            });

            describe(@"with only error examples", ^{
                beforeEach(^{
                    [group add:errorExample];
                    [group run];
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
                        [group run];
                    });

                    it(@"should be CDRExampleStateFailed", ^{
                        assertThatInt([group state], equalToInt(CDRExampleStateFailed));
                    });
                });

                describe(@"with at least one pending example", ^{
                    beforeEach(^{
                        [group add:pendingExample];
                        [group run];
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
                        [group run];
                    });

                    it(@"should be CDRExampleStateError", ^{
                        assertThatInt([group state], equalToInt(CDRExampleStateError));
                    });
                });

                describe(@"with at least one failing example", ^{
                    beforeEach(^{
                        [group add:failingExample];
                        [group run];
                    });

                    it(@"should be CDRExampleStateError", ^{
                        assertThatInt([group state], equalToInt(CDRExampleStateError));
                    });
                });

                describe(@"with at least one pending example", ^{
                    beforeEach(^{
                        [group add:pendingExample];
                        [group run];
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
                        [group run];
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
                    [group run];
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
                    [group run];
                    [group removeObserver:mockObserver forKeyPath:@"state"];

                    [mockObserver verify];
                });
            });

            describe(@"when a child example changes state, but the group state does not change", ^{
                beforeEach(^{
                    [group add:failingExample];
                    [failingExample run];

                    [group add:passingExample];
                    assertThatInt([group state], equalToInt(CDRExampleStateFailed));

                    mockObserver = [OCMockObject mockForClass:[NSObject class]];
                    [[[mockObserver stub] andThrow:[NSException exceptionWithName:@"name" reason:@"reason" userInfo:nil]] observeValueForKeyPath:@"state" ofObject:group change:[OCMArg any] context:NULL];
                });

                it(@"should not report that the state has changed", ^{
                    [group run];
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
                [passingExample run];
            });

            it(@"should be equal to 1", ^{
                assertThatFloat([group progress], equalToFloat(1.0));
            });
        });

        describe(@"when the group contains a mix of incomplete and complete children", ^{
            beforeEach(^{
                [group add:incompleteExample];
                [group add:passingExample];
                [passingExample run];
                [group add:failingExample];
                [failingExample run];
            });

            it(@"should be the mean of the progress of each child", ^{
                assertThatFloat([group progress], equalToFloat(2.0 / 3.0));
            });
        });
    });

    describe(@"message", ^{
        it(@"should return an empty string", ^{
            assertThat([group message], equalTo(@""));
        });
    });

    describe(@"hasFullText", ^{
        it(@"should return true", ^{
            assertThatBool([group hasFullText], equalToBool(true));
        });
        describe(@"when initialized normally", ^{
            it(@"should return true", ^{
                assertThatBool([group hasFullText], equalToBool(true));
            });
        });

        describe(@"when initialized as a root group", ^{
            beforeEach(^{
                [group release];
                group = [[CDRExampleGroup alloc] initWithText:@"I am a root group" isRoot:YES];
            });

            it(@"should return false", ^{
                assertThatBool([group hasFullText], equalToBool(false));
            });
        });
    });

    describe(@"fullText", ^{
        describe(@"with no parent", ^{
            beforeEach(^{
                assertThat([group parent], nilValue());
            });

            it(@"should return just its own text", ^{
                assertThat([group fullText], equalTo(groupText));
            });
        });

        describe(@"with a parent", ^{
            __block CDRExampleGroup *parentGroup;
            NSString *parentGroupText = @"Parent!";

            beforeEach(^{
                parentGroup = [[CDRExampleGroup alloc] initWithText:parentGroupText];
                [parentGroup add:group];
                assertThat([group parent], isNot(nilValue()));
            });

            afterEach(^{
                [parentGroup release];
            });

            it(@"should return its parent's text pre-pended with its own text", ^{
                assertThat([group fullText], equalTo([NSString stringWithFormat:@"%@ %@", parentGroupText, groupText]));
            });

            describe(@"when the parent also has a parent", ^{
                __block CDRExampleGroup *anotherGroup;
                NSString *anotherGroupText = @"Another Group!";

                beforeEach(^{
                    anotherGroup = [[CDRExampleGroup alloc] initWithText:anotherGroupText];
                    [anotherGroup add:parentGroup];
                });

                afterEach(^{
                    [anotherGroup release];
                });

                it(@"should include the text from all parents, pre-pended in the appopriate order", ^{
                    assertThat([group fullText], equalTo([NSString stringWithFormat:@"%@ %@ %@", anotherGroupText, parentGroupText, groupText]));
                });
            });
        });

        describe(@"with a root group as a parent", ^{
            __block CDRExampleGroup *rootGroup;

            beforeEach(^{
                rootGroup = [[CDRExampleGroup alloc] initWithText:@"wibble wobble" isRoot:YES];
                [rootGroup add:group];
                assertThat([group parent], isNot(nilValue()));
                assertThatBool([[group parent] hasFullText], equalToBool(NO));
            });

            it(@"should not include its parent's text", ^{
                assertThat([group fullText], equalTo([group text]));
            });
        });

    });
});

SPEC_END
