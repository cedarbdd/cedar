#import "Cedar.h"
#import "SimpleKeyValueObserver.h"
#import "FibonacciCalculator.h"
#import "CDRReportDispatcher.h"
#import <objc/runtime.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

extern void (^runInFocusedSpecsMode)(CDRExampleBase *, CDRReportDispatcher *);

SPEC_BEGIN(CDRExampleGroupSpec)

describe(@"CDRExampleGroup", ^{
    __block CDRExampleGroup *group;
    __block CDRExample *incompleteExample, *pendingExample, *passingExample, *failingExample, *errorExample, *nonFocusedExample;
    __block CDRReportDispatcher *dispatcher;
    NSString *groupText = @"Group!";

    beforeEach(^{
        dispatcher = nice_fake_for([CDRReportDispatcher class]);
        group = [[[CDRExampleGroup alloc] initWithText:groupText] autorelease];
        incompleteExample = [[[CDRExample alloc] initWithText:@"incomplete" andBlock:^{}] autorelease];
        passingExample = [[[CDRExample alloc] initWithText:@"I should pass" andBlock:^{}] autorelease];
        failingExample = [[[CDRExample alloc] initWithText:@"I should fail" andBlock:^{fail(@"I have failed.");}] autorelease];
        pendingExample = [[[CDRExample alloc] initWithText:@"I should pend" andBlock:nil] autorelease];
        errorExample = [[[CDRExample alloc] initWithText:@"I should raise an error" andBlock:^{ @throw @"wibble"; }] autorelease];
        nonFocusedExample = [[[CDRExample alloc] initWithText:@"I should not be focused" andBlock:^{}] autorelease];
    });

    describe(@"runWithDispatcher:", ^{
        beforeEach(^{
            [group add:passingExample];
            [group runWithDispatcher:dispatcher];
        });

        it(@"should tell the reporter the example group is about to start", ^{
            dispatcher should have_received(@selector(runWillStartExampleGroup:)).with(group);
        });

        it(@"should report each executed example in the group", ^{
            dispatcher should have_received(@selector(runWillStartExample:)).with(passingExample);
            dispatcher should have_received(@selector(runDidFinishExample:)).with(passingExample);
        });

        it(@"should tell the reporter when the group has finished", ^{
            dispatcher should have_received(@selector(runDidFinishExampleGroup:)).with(group);
        });

        describe(@"running it a second time", ^{
            it(@"should fail", ^{
                ^{ [group runWithDispatcher:dispatcher]; } should raise_exception.with_reason([NSString stringWithFormat:@"Attempt to run example group twice: %@", [group fullText]]);
            });
        });

        describe(@"releasing objects captured in spec blocks", ^{
            __block id weakCapturedObject;

            beforeEach(^{
                group = [[[CDRExampleGroup alloc] initWithText:groupText] autorelease];

                NSString *capturedObject = [@"abc" mutableCopy];
                objc_storeWeak(&weakCapturedObject, capturedObject);

                [group addBefore:^{
                    [capturedObject length];
                }];
                [group addAfter:^{
                    [capturedObject length];
                }];
                group.subjectActionBlock = ^{
                    [capturedObject length];
                };

                [capturedObject release]; capturedObject = nil;
                @autoreleasepool {
                    objc_loadWeak(&weakCapturedObject) should_not be_nil;
                }

                [group runWithDispatcher:dispatcher];
            });

            it(@"should allow captured objects to be deallocated once it has finished running", ^{
                objc_loadWeak(&weakCapturedObject) should be_nil;
            });
        });
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

    describe(@"afterEach", ^{
        __block NSInteger blockInvocationCount;

        beforeEach(^{
            blockInvocationCount = 0;
            CDRSpecBlock afterEachBlock = ^{ ++blockInvocationCount; };
            [group addAfter:afterEachBlock];
            [group add:errorExample];
            [group add:failingExample];
            [group add:passingExample];
            [group runWithDispatcher:dispatcher];
        });

        it(@"should be called after each example runs, regardless of failures or errors", ^{
            blockInvocationCount should equal(3);
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
                    [group runWithDispatcher:dispatcher];
                });

                it(@"should be CDRExampleStatePassed", ^{
                    CDRExampleState state = group.state;
                    expect(state).to(equal(CDRExampleStatePassed));
                });
            });

            describe(@"with only failing examples", ^{
                beforeEach(^{
                    [group add:failingExample];
                    [group runWithDispatcher:dispatcher];
                });

                it(@"should be CDRExampleStateFailed", ^{
                    CDRExampleState state = group.state;
                    expect(state).to(equal(CDRExampleStateFailed));
                });
            });

            describe(@"with only pending examples", ^{
                beforeEach(^{
                    [group add:pendingExample];
                    [group runWithDispatcher:dispatcher];
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
                    runInFocusedSpecsMode(group, dispatcher);
                });

                it(@"should be CDRExampleStateSkipped", ^{
                    CDRExampleState state = group.state;
                    expect(state).to(equal(CDRExampleStateSkipped));
                });
            });

            describe(@"with only error examples", ^{
                beforeEach(^{
                    [group add:errorExample];
                    [group runWithDispatcher:dispatcher];
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
                        runInFocusedSpecsMode(group, dispatcher);
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
                        [group runWithDispatcher:dispatcher];
                    });

                    it(@"should be CDRExampleStatePending", ^{
                        expect([group state]).to(equal(CDRExampleStatePending));
                    });
                });

                describe(@"with at least one skipped example", ^{
                    beforeEach(^{
                        pendingExample.focused = YES;
                        [group add:nonFocusedExample];
                        runInFocusedSpecsMode(group, dispatcher);
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
                        [group runWithDispatcher:dispatcher];
                    });

                    it(@"should be CDRExampleStateFailed", ^{
                        expect([group state]).to(equal(CDRExampleStateFailed));
                    });
                });

                describe(@"with at least one pending example", ^{
                    beforeEach(^{
                        [group add:pendingExample];
                        [group runWithDispatcher:dispatcher];
                    });

                    it(@"should be CDRExampleStateFailed", ^{
                        expect([group state]).to(equal(CDRExampleStateFailed));
                    });
                });

                describe(@"with at least one skipped example", ^{
                    beforeEach(^{
                        failingExample.focused = YES;
                        [group add:passingExample];
                        runInFocusedSpecsMode(group, dispatcher);
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
                        [group runWithDispatcher:dispatcher];
                    });

                    it(@"should be CDRExampleStateError", ^{
                        expect([group state]).to(equal(CDRExampleStateError));
                    });
                });

                describe(@"with at least one failing example", ^{
                    beforeEach(^{
                        [group add:failingExample];
                        [group runWithDispatcher:dispatcher];
                    });

                    it(@"should be CDRExampleStateError", ^{
                        expect([group state]).to(equal(CDRExampleStateError));
                    });
                });

                describe(@"with at least one pending example", ^{
                    beforeEach(^{
                        [group add:pendingExample];
                        [group runWithDispatcher:dispatcher];
                    });

                    it(@"should be CDRExampleStateError", ^{
                        expect([group state]).to(equal(CDRExampleStateError));
                    });
                });

                describe(@"with at least one skipped example", ^{
                    beforeEach(^{
                        errorExample.focused = YES;
                        [group add:nonFocusedExample];
                        runInFocusedSpecsMode(group, dispatcher);
                    });

                    it(@"should be CDRExampleStateError", ^{
                        expect([group state]).to(equal(CDRExampleStateError));
                    });
                });
            });
        });

        describe(@"with an afterEach that raises an exception", ^{
            __block CDRExample *passingExample2;
            __block CDRExample *failingExample2;

            beforeEach(^{
                CDRSpecBlock afterEachBlock = ^{ [[NSException exceptionWithName:@"Exception in afterEach" reason:@"afterEach exception - test execution should continue" userInfo:nil] raise]; };
                [group addAfter:afterEachBlock];
                [group add:passingExample];
                [group add:failingExample];

                CDRExampleGroup *childGroup = [[[CDRExampleGroup alloc] initWithText:@"child group" isRoot:NO] autorelease];
                passingExample2 = [[[CDRExample alloc] initWithText:@"I should pass" andBlock:^{}] autorelease];
                failingExample2 = [[[CDRExample alloc] initWithText:@"I should fail" andBlock:^{fail(@"I have failed.");}] autorelease];
                [childGroup add:passingExample2];
                [childGroup add:failingExample2];
                [group add:childGroup];

                [group runWithDispatcher:dispatcher];
            });

            it(@"should mark all passing examples be CDRExampleStateError", ^{
                passingExample.state should equal(CDRExampleStateError);
                passingExample2.state should equal(CDRExampleStateError);
            });

            it(@"should leave examples that have already failed alone", ^{
                failingExample.state should equal(CDRExampleStateFailed);
                failingExample2.state should equal(CDRExampleStateFailed);
            });
        });

        describe(@"KVO", ^{
            __block id mockObserver;

            beforeEach(^{
                mockObserver = [[[SimpleKeyValueObserver alloc] init] autorelease];
                spy_on(mockObserver);
            });

            describe(@"when a child changes state, causing the group to change state", ^{
                beforeEach(^{
                    [group add:passingExample];
                });

                it(@"should report that the state has changed", ^{
                    [group addObserver:mockObserver forKeyPath:@"state" options:0 context:NULL];
                    [group runWithDispatcher:dispatcher];
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
                    [group runWithDispatcher:dispatcher];
                    [group removeObserver:mockObserver forKeyPath:@"state"];

                    mockObserver should have_received("observeValueForKeyPath:ofObject:change:context:");
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
                [passingExample runWithDispatcher:dispatcher];
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
                [passingExample runWithDispatcher:dispatcher];
                [group add:failingExample];
                [failingExample runWithDispatcher:dispatcher];
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
                group = [[[CDRExampleGroup alloc] initWithText:@"I am a root group" isRoot:YES] autorelease];
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
                rootGroup = [[[CDRExampleGroup alloc] initWithText:@"wibble wobble" isRoot:YES] autorelease];
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

    describe(@"runTime", ^{
        __block CDRExample *firstExample;
        __block CDRExample *secondExample;
        __block CDRExampleGroup *exampleGroup;
        __block BOOL test;

        beforeEach(^{
            test = NO;
            FibonacciCalculator *calculator = [[[FibonacciCalculator alloc] init] autorelease];
            firstExample = [[[CDRExample alloc] initWithText:@"I'm Slow!" andBlock:^{
                [calculator computeFibonnaciNumberVeryVerySlowly:4];
            }] autorelease];
            secondExample = [[[CDRExample alloc] initWithText:@"I'm Slower!" andBlock:^{
                [calculator computeFibonnaciNumberVeryVerySlowly:5];
            }] autorelease];

            exampleGroup = [[[CDRExampleGroup alloc] initWithText:@"I have slow examples"] autorelease];
            [exampleGroup add:firstExample];
            [exampleGroup add:secondExample];
        });

        it(@"should return the running time of the test", ^{
            exampleGroup.runTime should equal(0);
            [exampleGroup runWithDispatcher:dispatcher];
            exampleGroup.runTime should be_greater_than(0);
            exampleGroup.runTime should be_greater_than_or_equal_to(firstExample.runTime + secondExample.runTime);
        });
    });

    describe(@"subjectActionBlock", ^{
        context(@"with a subject action block set", ^{
            CDRSpecBlock subjectActionBlock = ^{};

            beforeEach(^{
                group.subjectActionBlock = subjectActionBlock;
            });

            context(@"and with a parent", ^{
                __block CDRExampleGroup *parent;

                beforeEach(^{
                    parent = [[[CDRExampleGroup alloc] initWithText:@"Parent"] autorelease];
                    group.parent = parent;
                });

                context(@"which has a subject action block", ^{
                    CDRSpecBlock parentsubjectActionBlock = ^{};

                    beforeEach(^{
                        parent.subjectActionBlock = parentsubjectActionBlock;
                    });

                    it(@"should raise a duplicate subject action block exception", ^{
                        __block id dummy;
                        ^{ dummy = group.subjectActionBlock; } should raise_exception;
                    });
                });

                context(@"which does not have a subject action block", ^{
                    beforeEach(^{
                        parent.subjectActionBlock should_not be_truthy;
                    });

                    it(@"should return its subject action block", ^{
                        group.subjectActionBlock should equal(subjectActionBlock);
                    });
                });
            });

            context(@"and with no parent", ^{
                beforeEach(^{
                    group.parent should be_nil;
                });

                it(@"should return its subject action block", ^{
                    group.subjectActionBlock should equal(subjectActionBlock);
                });
            });
        });

        context(@"with no subject action block set", ^{
            context(@"and with a parent", ^{
                __block CDRExampleGroup *parent;

                beforeEach(^{
                    parent = [[[CDRExampleGroup alloc] initWithText:@"Parent"] autorelease];
                    group.parent = parent;
                });

                context(@"which has a subject action block", ^{
                    CDRSpecBlock parentsubjectActionBlock = ^{};

                    beforeEach(^{
                        parent.subjectActionBlock = parentsubjectActionBlock;
                    });

                    it(@"should return its parent's subject action block", ^{
                        group.subjectActionBlock should equal(parentsubjectActionBlock);
                    });
                });

                context(@"which does not have a subject action block", ^{
                    beforeEach(^{
                        parent.subjectActionBlock should_not be_truthy;
                    });

                    it(@"should return nil", ^{
                        group.subjectActionBlock should_not be_truthy;
                    });
                });
            });

            context(@"and with no parent", ^{
                beforeEach(^{
                    group.parent should be_nil;
                });

                it(@"should return nil", ^{
                    group.subjectActionBlock should_not be_truthy;
                });
            });
        });
    });
});

SPEC_END
