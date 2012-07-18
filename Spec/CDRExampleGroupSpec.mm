#if TARGET_OS_IPHONE
// Normally you would include this file out of the framework.  However, we're
// testing the framework here, so including the file from the framework will
// conflict with the compiler attempting to include the file from the project.
#import "SpecHelper.h"
#else
#import <Cedar/SpecHelper.h>
#endif

#import "CDRExampleBase.h"
#import "CDRExampleGroup.h"
#import "CDRExample.h"
#import "NoOpKeyValueObserver.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

extern void (^runInFocusedSpecsMode)(CDRExampleBase *);

SPEC_BEGIN(CDRExampleGroupSpec)

describe(@"CDRExampleGroup", ^{
    __block CDRExampleGroup *group;
    __block CDRExample *incompleteExample, *pendingExample, *passingExample, *failingExample, *errorExample, *nonFocusedExample;
    NSString *groupText = @"Group!";

    beforeEach(^{
        group = [[CDRExampleGroup alloc] initWithText:groupText];
        incompleteExample = [[CDRExample alloc] initWithText:@"incomplete" andBlock:^{}];
        passingExample = [[CDRExample alloc] initWithText:@"I should pass" andBlock:^{}];
        failingExample = [[CDRExample alloc] initWithText:@"I should fail" andBlock:^{fail(@"I have failed.");}];
        pendingExample = [[CDRExample alloc] initWithText:@"I should pend" andBlock:nil];
        errorExample = [[CDRExample alloc] initWithText:@"I should raise an error" andBlock:^{ @throw @"wibble"; }];
        nonFocusedExample = [[CDRExample alloc] initWithText:@"I should not be focused" andBlock:^{}];
    });

    afterEach(^{
        [errorExample release];
        [pendingExample release];
        [failingExample release];
        [passingExample release];
        [incompleteExample release];
        [nonFocusedExample release];
        [group release];
    });

    describe(@"hasChildren", ^{
        describe(@"for an empty group", ^{
            beforeEach(^{
                NSUInteger count = group.examples.count;
                expect(count).to(equal(0));
            });

            it(@"should return false", ^{
                BOOL hasChildren = group.hasChildren;
                expect(hasChildren).to_not(be_truthy());
            });
        });

        describe(@"for a non-empty group", ^{
            beforeEach(^{
                [group add:incompleteExample];
                NSUInteger count = group.examples.count;
                expect(count).to_not(equal(0));
            });

            it(@"should return true", ^{
                BOOL hasChildren = group.hasChildren;
                expect(hasChildren).to(be_truthy());
            });
        });
    });

    describe(@"isFocused", ^{
        it(@"should return false by default", ^{
            expect([group isFocused]).to_not(be_truthy());
        });

        it(@"should return false when group is not focused", ^{
            group.focused = NO;
            expect([group isFocused]).to_not(be_truthy());
        });

        it(@"should return true when group is focused", ^{
            group.focused = YES;
            expect([group isFocused]).to(be_truthy());
        });
    });

    describe(@"hasFocusedExamples", ^{
        context(@"for a group that is focused", ^{
            beforeEach(^{
                group.focused = YES;
            });

            it(@"should return true", ^{
                expect([group hasFocusedExamples]).to(be_truthy());
            });
        });

        context(@"for a group that is not focused", ^{
            beforeEach(^{
                expect([group isFocused]).to_not(be_truthy());
            });

            it(@"should return false", ^{
                expect([group hasFocusedExamples]).to_not(be_truthy());
            });

            context(@"and has at least one focused example", ^{
                beforeEach(^{
                    [group add:failingExample];
                    [group add:passingExample];
                    passingExample.focused = YES;
                });

                it(@"should return true", ^{
                    expect([group hasFocusedExamples]).to(be_truthy());
                });
            });

            context(@"and has at least one focused group", ^{
                beforeEach(^{
                    CDRExampleGroup *innerGroup = [[CDRExampleGroup alloc] initWithText:@"Inner group"];
                    innerGroup.focused = YES;
                    [group add:innerGroup];

                    CDRExampleGroup *anotherInnerGroup = [[CDRExampleGroup alloc] initWithText:@"Another inner group"];
                    [group add:anotherInnerGroup];

                    [innerGroup release];
                    [anotherInnerGroup release];
                });

                it(@"should return true", ^{
                    expect([group hasFocusedExamples]).to(be_truthy());
                });
            });
        });
    });

    describe(@"state", ^{
        describe(@"for a group containing no examples", ^{
            beforeEach(^{
                NSUInteger count = group.examples.count;
                expect(count).to(equal(0));
            });

            it(@"should be CDRExampleStatePending", ^{
                CDRExampleState state = group.state;
                expect(state).to(equal(CDRExampleStatePending));
            });
        });

        describe(@"for a group containing at least one incomplete example", ^{
            beforeEach(^{
                [group add:incompleteExample];
            });

            it(@"should be CDRExampleStateIncomplete", ^{
                CDRExampleState state = group.state;
                expect(state).to(equal(CDRExampleStateIncomplete));
            });
        });

        describe(@"for a group containing only complete examples", ^{
            describe(@"with only passing examples", ^{
                beforeEach(^{
                    [group add:passingExample];
                    [group run];
                });

                it(@"should be CDRExampleStatePassed", ^{
                    CDRExampleState state = group.state;
                    expect(state).to(equal(CDRExampleStatePassed));
                });
            });

            describe(@"with only failing examples", ^{
                beforeEach(^{
                    [group add:failingExample];
                    [group run];
                });

                it(@"should be CDRExampleStateFailed", ^{
                    CDRExampleState state = group.state;
                    expect(state).to(equal(CDRExampleStateFailed));
                });
            });

            describe(@"with only pending examples", ^{
                beforeEach(^{
                    [group add:pendingExample];
                    [group run];
                });

                it(@"should be CDRExampleStatePending", ^{
                    CDRExampleState state = group.state;
                    expect(state).to(equal(CDRExampleStatePending));
                });
            });

            describe(@"with only skipped examples", ^{
                beforeEach(^{
                    [group add:passingExample];
                    passingExample.focused = NO;
                    runInFocusedSpecsMode(group);
                });

                it(@"should be CDRExampleStateSkipped", ^{
                    CDRExampleState state = group.state;
                    expect(state).to(equal(CDRExampleStateSkipped));
                });
            });

            describe(@"with only error examples", ^{
                beforeEach(^{
                    [group add:errorExample];
                    [group run];
                });

                it(@"should be CDRExampleStateError", ^{
                    CDRExampleState state = group.state;
                    expect(state).to(equal(CDRExampleStateError));
                });
            });

            describe(@"with at least one passing example", ^{
                beforeEach(^{
                    [group add:passingExample];
                });

                describe(@"with at least one skipped example", ^{
                    beforeEach(^{
                        passingExample.focused = YES;
                        [group add:nonFocusedExample];
                        runInFocusedSpecsMode(group);
                    });

                    it(@"should be CDRExampleStatePassed", ^{
                        expect([group state]).to(equal(CDRExampleStatePassed));
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
                        expect([group state]).to(equal(CDRExampleStatePending));
                    });
                });

                describe(@"with at least one skipped example", ^{
                    beforeEach(^{
                        pendingExample.focused = YES;
                        [group add:nonFocusedExample];
                        runInFocusedSpecsMode(group);
                    });

                    it(@"should be CDRExampleStatePending", ^{
                        CDRExampleState state = group.state;
                        expect(state).to(equal(CDRExampleStatePending));
                    });
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
                        expect([group state]).to(equal(CDRExampleStateFailed));
                    });
                });

                describe(@"with at least one pending example", ^{
                    beforeEach(^{
                        [group add:pendingExample];
                        [group run];
                    });

                    it(@"should be CDRExampleStateFailed", ^{
                        expect([group state]).to(equal(CDRExampleStateFailed));
                    });
                });

                describe(@"with at least one skipped example", ^{
                    beforeEach(^{
                        failingExample.focused = YES;
                        [group add:passingExample];
                        runInFocusedSpecsMode(group);
                    });

                    it(@"should be CDRExampleStateFailed", ^{
                        expect([group state]).to(equal(CDRExampleStateFailed));
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
                        expect([group state]).to(equal(CDRExampleStateError));
                    });
                });

                describe(@"with at least one failing example", ^{
                    beforeEach(^{
                        [group add:failingExample];
                        [group run];
                    });

                    it(@"should be CDRExampleStateError", ^{
                        expect([group state]).to(equal(CDRExampleStateError));
                    });
                });

                describe(@"with at least one pending example", ^{
                    beforeEach(^{
                        [group add:pendingExample];
                        [group run];
                    });

                    it(@"should be CDRExampleStateError", ^{
                        expect([group state]).to(equal(CDRExampleStateError));
                    });
                });

                describe(@"with at least one skipped example", ^{
                    beforeEach(^{
                        errorExample.focused = YES;
                        [group add:nonFocusedExample];
                        runInFocusedSpecsMode(group);
                    });

                    it(@"should be CDRExampleStateError", ^{
                        expect([group state]).to(equal(CDRExampleStateError));
                    });
                });
            });
        });

        describe(@"KVO", ^{
            __block id mockObserver;

            beforeEach(^{
                mockObserver = [[[NoOpKeyValueObserver alloc] init] autorelease];
                spy_on(mockObserver);
            });

            describe(@"when a child changes state, causing the group to change state", ^{
                beforeEach(^{
                    [group add:passingExample];
                });

                it(@"should report that the state has changed", ^{
                    [group addObserver:mockObserver forKeyPath:@"state" options:0 context:NULL];
                    [group run];
                    [group removeObserver:mockObserver forKeyPath:@"state"];

                    mockObserver should have_received("observeValueForKeyPath:ofObject:change:context:");
                });
            });

            describe(@"when a child's child changes state, causing the child group to change state, causing the top-level group to change state", ^{
                __block CDRExampleGroup *subgroup;

                beforeEach(^{
                    subgroup = [[CDRExampleGroup alloc] initWithText:@"subgroup"];
                    [group add:subgroup];
                    [subgroup release];

                    [subgroup add:passingExample];
                });

                it(@"should report that the state has changed", ^{
                    [group addObserver:mockObserver forKeyPath:@"state" options:0 context:NULL];
                    [group run];
                    [group removeObserver:mockObserver forKeyPath:@"state"];

                    mockObserver should have_received("observeValueForKeyPath:ofObject:change:context:");
                });
            });

            describe(@"when a child example changes state, but the group state does not change", ^{
                beforeEach(^{
                    [group add:failingExample];
                    [failingExample run];

                    [group add:passingExample];
                    CDRExampleState state = group.state;
                    expect(state).to(equal(CDRExampleStateFailed));

                    mockObserver stub_method("observeValueForKeyPath:ofObject:change:context:").and_raise_exception();
                });

                it(@"should not report that the state has changed", ^{
                    [group run];
                    CDRExampleState state = group.state;
                    expect(state).to(equal(CDRExampleStateFailed));
                });
            });
        });
    });

    describe(@"progress", ^{
        describe(@"when the group is empty", ^{
            beforeEach(^{
                NSUInteger count = group.examples.count;
                expect(count).to(equal(0));
            });

            it(@"should be equal to 1", ^{
                float progress = group.progress;
                expect(progress).to(equal(1));
            });
        });

        describe(@"when the group contains all incomplete children", ^{
            beforeEach(^{
                [group add:incompleteExample];
            });

            it(@"should be equal to 0", ^{
                float progress = group.progress;
                expect(progress).to(equal(0));
            });
        });

        describe(@"when the group contains all complete children", ^{
            beforeEach(^{
                [group add:passingExample];
                [passingExample run];
            });

            it(@"should be equal to 1", ^{
                float progress = group.progress;
                expect(progress).to(equal(1));
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
                float progress = group.progress;
                expect(progress).to(be_close_to(2.0 / 3.0));
            });
        });
    });

    describe(@"message", ^{
        it(@"should return an empty string", ^{
            NSString *message = group.message;
            expect(message).to(equal(@""));
        });
    });

    describe(@"hasFullText", ^{
        it(@"should return true", ^{
            BOOL hasFullText = group.hasFullText;
            expect(hasFullText).to(equal(YES));
        });

        describe(@"when initialized normally", ^{
            it(@"should return true", ^{
                BOOL hasFullText = group.hasFullText;
                expect(hasFullText).to(equal(YES));
            });
        });

        describe(@"when initialized as a root group", ^{
            beforeEach(^{
                [group release];
                group = [[CDRExampleGroup alloc] initWithText:@"I am a root group" isRoot:YES];
            });

            it(@"should return false", ^{
                BOOL hasFullText = group.hasFullText;
                expect(hasFullText).to(equal(NO));
            });
        });
    });

    describe(@"fullText/fullTextInPieces", ^{
        describe(@"with no parent", ^{
            beforeEach(^{
                id<CDRExampleParent> parent = group.parent;
                expect(parent).to(be_nil());
            });

            it(@"should return just its own text", ^{
                NSString *fullText = group.fullText;
                expect(fullText).to(equal(groupText));
            });

            it(@"should return just its own text in one piece", ^{
                NSArray *fullTextPieces = group.fullTextInPieces;
                expect([fullTextPieces isEqual:[NSArray arrayWithObject:groupText]]).to(be_truthy());
            });
        });

        describe(@"with a parent", ^{
            __block CDRExampleGroup *parentGroup;
            NSString *parentGroupText = @"Parent!";

            beforeEach(^{
                parentGroup = [[[CDRExampleGroup alloc] initWithText:parentGroupText] autorelease];
                [parentGroup add:group];

                id<CDRExampleParent> parent = group.parent;
                expect(parent).to_not(be_nil());
            });

            it(@"should return its parent's text pre-pended with its own text", ^{
                NSString *fullText = group.fullText;
                expect(fullText).to(equal([NSString stringWithFormat:@"%@ %@", parentGroupText, groupText]));
            });

            it(@"should return its parent's text pre-pended with its own text in pieces", ^{
                NSArray *fullTextPieces = group.fullTextInPieces;
                NSArray *expectedPieces = [NSArray arrayWithObjects:parentGroupText, groupText, nil];
                expect([fullTextPieces isEqual:expectedPieces]).to(be_truthy());
            });

            describe(@"when the parent also has a parent", ^{
                __block CDRExampleGroup *anotherGroup;
                NSString *anotherGroupText = @"Another Group!";

                beforeEach(^{
                    anotherGroup = [[[CDRExampleGroup alloc] initWithText:anotherGroupText] autorelease];
                    [anotherGroup add:parentGroup];
                });

                it(@"should include the text from all parents, pre-pended in the appopriate order", ^{
                    NSString *fullText = group.fullText;
                    expect(fullText).to(equal([NSString stringWithFormat:@"%@ %@ %@", anotherGroupText, parentGroupText, groupText]));
                });

                it(@"should include the text from all parents, pre-pended in the appopriate order in pieces", ^{
                    NSArray *fullTextPieces = group.fullTextInPieces;
                    NSArray *expectedPieces = [NSArray arrayWithObjects:anotherGroupText, parentGroupText, groupText, nil];
                    expect([fullTextPieces isEqual:expectedPieces]).to(be_truthy());
                });
            });
        });

        describe(@"with a root group as a parent", ^{
            __block CDRExampleGroup *rootGroup;

            beforeEach(^{
                rootGroup = [[CDRExampleGroup alloc] initWithText:@"wibble wobble" isRoot:YES];
                [rootGroup add:group];

                id<CDRExampleParent> parent = group.parent;
                expect(parent).to_not(be_nil());

                BOOL hasFullText = group.parent.hasFullText;
                expect(hasFullText).to_not(be_truthy());
            });

            it(@"should not include its parent's text", ^{
                NSString *fullText = group.fullText;
                NSString *text = group.text;
                expect(fullText).to(equal(text));
            });

            it(@"should not include its parent's text in pieces", ^{
                NSArray *fullTextPieces = group.fullTextInPieces;
                NSString *text = group.text;
                expect([fullTextPieces isEqual:[NSArray arrayWithObject:text]]).to(be_truthy());
            });
        });
    });
});

SPEC_END
