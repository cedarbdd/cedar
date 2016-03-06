#import "Cedar.h"
#import "SimpleKeyValueObserver.h"
#import "FibonacciCalculator.h"
#import "CDRReportDispatcher.h"
#import <objc/runtime.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

void (^runInFocusedSpecsMode)(CDRExampleBase *, CDRReportDispatcher *) = ^(CDRExampleBase *example, CDRReportDispatcher *dispatcher) {
    BOOL before = [CDRSpecHelper specHelper].shouldOnlyRunFocused;
    [CDRSpecHelper specHelper].shouldOnlyRunFocused = YES;
    @try {
        [example runWithDispatcher:dispatcher];
    } @finally {
        [CDRSpecHelper specHelper].shouldOnlyRunFocused = before;
    }
};

SPEC_BEGIN(CDRExampleSpec)

typedef void (^CDRSharedExampleBlock)(NSDictionary *context);

CDRSharedExampleBlock sharedExampleMethod = [^(NSDictionary *context) {
    __block CDRExample *example;
    __block NSString *exampleText;

    beforeEach(^{
        example = [context valueForKey:@"example"];
        exampleText = [context valueForKey:@"exampleText"];
    });

    describe(@"with no parent", ^{
        beforeEach(^{
            id parent = example.parent;
            expect(parent).to(be_nil());
        });

        it(@"should return just its own text", ^{
            NSString *fullText = example.fullText;
            expect(fullText).to(equal(exampleText));
        });

        it(@"should return just its own text in one piece", ^{
            NSArray *fullTextPieces = example.fullTextInPieces;
            expect([fullTextPieces isEqual:[NSArray arrayWithObject:exampleText]]).to(be_truthy());
        });
    });

    describe(@"with a parent", ^{
        __block CDRExampleGroup *group;
        NSString *groupText = @"Parent!";

        beforeEach(^{
            group = [[[CDRExampleGroup alloc] initWithText:groupText] autorelease];
            [group add:example];
            expect(example.parent).to_not(be_nil());
        });

        it(@"should return its parent's text prepended with its own text", ^{
            NSString *fullText = example.fullText;
            expect(fullText).to(equal([NSString stringWithFormat:@"%@ %@", groupText, exampleText]));
        });

        it(@"should return its parent's text pre-pended with its own text in pieces", ^{
            NSArray *fullTextPieces = example.fullTextInPieces;
            NSArray *expectedPieces = [NSArray arrayWithObjects:groupText, exampleText, nil];
            expect([fullTextPieces isEqual:expectedPieces]).to(be_truthy());
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

            it(@"should include the text from all parents, pre-pended in the appropriate order", ^{
                NSString *fullText = example.fullText;
                expect(fullText).to(equal([NSString stringWithFormat:@"%@ %@ %@", rootGroupText, groupText, exampleText]));
            });

            it(@"should include the text from all parents, pre-pended in the appopriate order in pieces", ^{
                NSArray *fullTextPieces = example.fullTextInPieces;
                NSArray *expectedPieces = [NSArray arrayWithObjects:rootGroupText, groupText, exampleText, nil];
                expect([fullTextPieces isEqual:expectedPieces]).to(be_truthy());
            });
        });
    });

    describe(@"with a root group as a parent", ^{
        __block CDRExampleGroup *rootGroup;

        beforeEach(^{
            rootGroup = [[[CDRExampleGroup alloc] initWithText:@"wibble wobble" isRoot:YES] autorelease];
            [rootGroup add:example];

            expect(example.parent).to_not(be_nil());
            BOOL hasFullText = example.parent.hasFullText;
            expect(hasFullText).to_not(be_truthy());
        });

        it(@"should not include its parent's text", ^{
            expect(example.fullText).to(equal(example.text));
        });

        it(@"should not include its parent's text in pieces", ^{
            NSArray *fullTextPieces = example.fullTextInPieces;
            NSString *text = example.text;
            expect([fullTextPieces isEqual:[NSArray arrayWithObject:text]]).to(be_truthy());
        });
    });
} copy];

describe(@"CDRExample", ^{
    __block CDRExample *example;
    __block CDRReportDispatcher *dispatcher;
    NSString *exampleText = @"Example!";
    __block BOOL beforeFocused;

    beforeEach(^{
        dispatcher = nice_fake_for([CDRReportDispatcher class]);
        example = [[[CDRExample alloc] initWithText:exampleText andBlock:^{}] autorelease];

        // if you focus any of these specs, they will fail without this
        beforeFocused = [CDRSpecHelper specHelper].shouldOnlyRunFocused;
        [CDRSpecHelper specHelper].shouldOnlyRunFocused = NO;
        // end
    });

    afterEach(^{
        [CDRSpecHelper specHelper].shouldOnlyRunFocused = beforeFocused;
    });

    describe(@"runWithDispatcher:", ^{
        __block CDRReportDispatcher *dispatcher;
        __block id weakCapturedObject;

        beforeEach(^{
            dispatcher = nice_fake_for([CDRReportDispatcher class]);
        });

        beforeEach(^{
            NSString *capturedObject = [@"abc" mutableCopy];
            objc_storeWeak(&weakCapturedObject, capturedObject);

            example = [[[CDRExample alloc] initWithText:exampleText andBlock:^{
                // so we don't get a zero-value for runTime
                [NSThread sleepForTimeInterval:0.01];
                [capturedObject length];
            }] autorelease];

            [capturedObject release]; capturedObject = nil;
            @autoreleasepool {
                objc_loadWeak(&weakCapturedObject) should_not be_nil;
            }

            // assert example is populated at the appropriate times
            dispatcher stub_method(@selector(runWillStartExample:)).and_do(^(NSInvocation *invocation) {
                example.state should equal(CDRExampleStateIncomplete);
                example.runTime should equal(0);
                example.startDate should_not be_nil;
                example.endDate should be_nil;
            });
            dispatcher stub_method(@selector(runDidFinishExample:)).and_do(^(NSInvocation *invocation) {
                example.state should equal(CDRExampleStatePassed);
                example.runTime should_not equal(0);
                example.endDate should_not be_nil;
            });

            [example runWithDispatcher:dispatcher];
        });

        it(@"should report the example", ^{
            dispatcher should have_received(@selector(runWillStartExample:)).with(example);
            dispatcher should have_received(@selector(runDidFinishExample:)).with(example);
        });

        it(@"should have its start date less than its end date", ^{
            [example.endDate timeIntervalSinceDate:example.startDate] should be_greater_than(0);
        });

        describe(@"running it a second time", ^{
            it(@"should fail", ^{
                ^{ [example runWithDispatcher:dispatcher]; } should raise_exception.with_reason([NSString stringWithFormat:@"Attempt to run example twice: %@", [example fullText]]);
            });
        });

        it(@"should allow captured objects to be deallocated once it has finished running", ^{
            objc_loadWeak(&weakCapturedObject) should be_nil;
        });
    });

    describe(@"hasChildren", ^{
        it(@"should return false", ^{
            BOOL hasChildren = example.hasChildren;
            expect(hasChildren).to_not(be_truthy());
        });
    });

    describe(@"isFocused", ^{
        it(@"should return false by default", ^{
            expect([example isFocused]).to_not(be_truthy());
        });

        it(@"should return false when example is not focused", ^{
            example.focused = NO;
            expect([example isFocused]).to_not(be_truthy());
        });

        it(@"should return true when example is focused", ^{
            example.focused = YES;
            expect([example isFocused]).to(be_truthy());
        });
    });

    describe(@"hasFocusedExamples", ^{
        it(@"should return false by default", ^{
            expect([example hasFocusedExamples]).to_not(be_truthy());
        });

        it(@"should return false when example is not focused", ^{
            example.focused = NO;
            expect([example hasFocusedExamples]).to_not(be_truthy());
        });

        it(@"should return true when example is focused", ^{
            example.focused = YES;
            expect([example hasFocusedExamples]).to(be_truthy());
        });
    });

    describe(@"state", ^{
        context(@"for a newly created example", ^{
            it(@"should be CDRExampleStateIncomplete", ^{
                CDRExampleState state = example.state;
                expect(state).to(equal(CDRExampleStateIncomplete));
            });
        });

        context(@"for an example that has run and succeeded", ^{
            beforeEach(^{
                [example runWithDispatcher:dispatcher];
            });

            it(@"should be CDRExampleStatePassed", ^{
                CDRExampleState state = example.state;
                expect(state).to(equal(CDRExampleStatePassed));
            });
        });

        describe(@"for an example that has run and failed", ^{
            beforeEach(^{
                example = [[[CDRExample alloc] initWithText:@"I should fail" andBlock:^{ fail(@"fail"); }] autorelease];
                [example runWithDispatcher:dispatcher];
            });

            it(@"should be CDRExampleStateFailed", ^{
                CDRExampleState state = example.state;
                expect(state).to(equal(CDRExampleStateFailed));
            });
        });

        describe(@"for an example that has run and thrown an NSException", ^{
            beforeEach(^{
                example = [[[CDRExample alloc] initWithText:@"I should throw an NSException" andBlock:^{ [[NSException exceptionWithName:@"name" reason:@"reason" userInfo:nil] raise]; }] autorelease];
                [example runWithDispatcher:dispatcher];
            });

            it(@"should be CDRExampleStateError", ^{
                CDRExampleState state = example.state;
                expect(state).to(equal(CDRExampleStateError));
            });
        });

        describe(@"for an example that has run and thrown something other than an NSException", ^{
            beforeEach(^{
                example = [[[CDRExample alloc] initWithText:@"I should throw some nonsense" andBlock:^{ @throw @"Some nonsense"; }] autorelease];
                [example runWithDispatcher:dispatcher];
            });

            it(@"should be CDRExampleStateError", ^{
                CDRExampleState state = example.state;
                expect(state).to(equal(CDRExampleStateError));
            });
        });

        describe(@"for a pending example", ^{
            beforeEach(^{
                example = [[[CDRExample alloc] initWithText:@"I should be pending" andBlock:PENDING] autorelease];
                [example runWithDispatcher:dispatcher];
            });

            it(@"should be CDRExampleStatePending", ^{
                CDRExampleState state = example.state;
                expect(state).to(equal(CDRExampleStatePending));
            });
        });

        context(@"when running in the focused specs mode", ^{
            context(@"for an example that was focused", ^{
                beforeEach(^{
                    example.focused = YES;
                });

                it(@"should be CDRExampleStatePassed", ^{
                    runInFocusedSpecsMode(example, dispatcher);
                    expect([example state]).to(equal(CDRExampleStatePassed));
                });
            });

            context(@"for an example that was not focused", ^{
                beforeEach(^{
                    example.focused = NO;
                });

                context(@"and its parent group was focused", ^{
                    beforeEach(^{
                        CDRExampleGroup *parentGroup = [[[CDRExampleGroup alloc] initWithText:@"Parent group"] autorelease];
                        parentGroup.focused = YES;
                        example.parent = parentGroup;
                    });

                    it(@"should be CDRExampleStatePassed", ^{
                        runInFocusedSpecsMode(example, dispatcher);
                        expect([example state]).to(equal(CDRExampleStatePassed));
                    });
                });

                context(@"and its parent group was not focused", ^{
                    __block CDRExampleGroup *parentGroup;

                    beforeEach(^{
                        parentGroup = [[[CDRExampleGroup alloc] initWithText:@"Parent group"] autorelease];
                        parentGroup.focused = NO;
                        example.parent = parentGroup;
                    });

                    it(@"should be CDRExampleStateSkipped", ^{
                        runInFocusedSpecsMode(example, dispatcher);
                        expect([example state]).to(equal(CDRExampleStateSkipped));
                    });

                    context(@"and its parent's parent group was focused", ^{
                        beforeEach(^{
                            CDRExampleGroup *parentsParentGroup = [[[CDRExampleGroup alloc] initWithText:@"Parent's parent group"] autorelease];
                            parentsParentGroup.focused = YES;
                            parentGroup.parent = parentsParentGroup;
                        });

                        it(@"should be CDRExampleStatePassed", ^{
                            runInFocusedSpecsMode(example, dispatcher);
                            expect([example state]).to(equal(CDRExampleStatePassed));
                        });
                    });
                });
            });
        });

        describe(@"KVO", ^{
            __block id mockObserver;

            beforeEach(^{
                mockObserver = [[[SimpleKeyValueObserver alloc] init] autorelease];
                spy_on(mockObserver);
            });

            it(@"should report when the state of a non-collection property changes", ^{
                [example addObserver:mockObserver forKeyPath:@"state" options:0 context:NULL];
                [example runWithDispatcher:dispatcher];
                [example removeObserver:mockObserver forKeyPath:@"state"];

                mockObserver should have_received("observeValueForKeyPath:ofObject:change:context:");
            });
        });
    });

    describe(@"progress", ^{
        describe(@"when the state is incomplete", ^{
            beforeEach(^{
                CDRExampleState state = example.state;
                expect(state).to(equal(CDRExampleStateIncomplete));
            });

            it(@"should return 0", ^{
                float progress = example.progress;
                expect(progress).to(equal(0.0));
            });
        });

        describe(@"when the state is passed", ^{
            beforeEach(^{
                [example runWithDispatcher:dispatcher];
                CDRExampleState state = example.state;
                expect(state).to(equal(CDRExampleStatePassed));
            });

            it(@"should return 1", ^{
                float progress = example.progress;
                expect(progress).to(equal(1.0));
            });
        });
    });

    describe(@"fullText/fullTextInPieces", ^{
        __block NSMutableDictionary *sharedExampleContext = [NSMutableDictionary dictionary];

        beforeEach(^{
            [sharedExampleContext setObject:example forKey:@"example"];
            [sharedExampleContext setObject:exampleText forKey:@"exampleText"];
        });

        sharedExampleMethod(sharedExampleContext);
    });

    describe(@"message", ^{
        describe(@"for an incomplete example", ^{
            beforeEach(^{
                CDRExampleState state = example.state;
                expect(state).to(equal(CDRExampleStateIncomplete));
            });

            it(@"should return an empty string", ^{
                NSString *message = example.message;
                expect(message).to(equal(@""));
            });
        });

        describe(@"for a passing example", ^{
            beforeEach(^{
                example = [[[CDRExample alloc] initWithText:@"I should pass" andBlock:^{}] autorelease];
                [example runWithDispatcher:dispatcher];
            });

            it(@"should return an empty string", ^{
                NSString *message = example.message;
                expect(message).to(equal(@""));
            });
        });

        describe(@"for a pending example", ^{
            beforeEach(^{
                example = [[[CDRExample alloc] initWithText:@"I should pend" andBlock:nil] autorelease];
                [example runWithDispatcher:dispatcher];
            });

            it(@"should return an empty string", ^{
                NSString *message = example.message;
                expect(message).to(equal(@""));
            });
        });

        describe(@"for a skipped example", ^{
            beforeEach(^{
                example = [[[CDRExample alloc] initWithText:@"I should pend" andBlock:nil] autorelease];
                example.focused = NO;
                runInFocusedSpecsMode(example, dispatcher);
            });

            it(@"should return an empty string", ^{
                NSString *message = example.message;
                expect(message).to(equal(@""));
            });
        });

        describe(@"for a failing example", ^{
            __block NSString *failureMessage = @"I should fail";

            beforeEach(^{
                example = [[[CDRExample alloc] initWithText:@"I should fail" andBlock:^{[[CDRSpecFailure specFailureWithReason:failureMessage] raise];}] autorelease];
                [example runWithDispatcher:dispatcher];
            });

            it(@"should return the failure message", ^{
                NSString *message = example.message;
                expect(message).to(equal(failureMessage));
            });
        });

        describe(@"for an example that throws an NSException", ^{
            __block NSException *exception;

            beforeEach(^{
                exception = [NSException exceptionWithName:@"name" reason:@"reason" userInfo:nil];

                example = [[[CDRExample alloc] initWithText:@"I should throw an exception" andBlock:^{ [exception raise]; }] autorelease];
                [example runWithDispatcher:dispatcher];
            });

            it(@"should return the description of the exception", ^{
                expect(example.message).to(equal(exception.description));
            });
        });

        describe(@"for an example that throws a non-NSException", ^{
            __block NSString *failureMessage = @"wibble wobble";

            beforeEach(^{
                example = [[[CDRExample alloc] initWithText:@"I should throw an exception" andBlock:^{ @throw failureMessage; }] autorelease];
                [example runWithDispatcher:dispatcher];
            });

            it(@"should return the description of whatever was thrown", ^{
                NSString *message = example.message;
                expect(message).to(equal(failureMessage));
            });
        });
    });

    describe(@"isPending", ^{
        context(@"for an example with a block", ^{
            it(@"should not report itself as pending", ^{
                [example isPending] should be_falsy;
            });

            context(@"after it has run", ^{
                beforeEach(^{
                    [example runWithDispatcher:dispatcher];
                });

                it(@"should not report itself as pending", ^{
                    [example isPending] should be_falsy;
                });
            });

        });

        context(@"for a pending example", ^{
            beforeEach(^{
                example = [[[CDRExample alloc] initWithText:@"I should be pending" andBlock:PENDING] autorelease];
            });

            it(@"should report itself as pending", ^{
                [example isPending] should be_truthy;
            });

            context(@"after it has run", ^{
                beforeEach(^{
                    [example runWithDispatcher:dispatcher];
                });

                it(@"should report itself as pending", ^{
                    [example isPending] should be_truthy;
                });
            });
        });
    });

    describe(@"runTime", ^{
        __block CDRExample *fastExample;
        __block CDRExample *slowExample;
        __block BOOL test;

        beforeEach(^{
            test = NO;
            FibonacciCalculator *calculator = [[[FibonacciCalculator alloc] init] autorelease];
            fastExample = [[[CDRExample alloc] initWithText:@"I'm Fast!" andBlock:^{
                [calculator computeFibonnaciNumberVeryVeryQuickly:33];
            }] autorelease];
            slowExample = [[[CDRExample alloc] initWithText:@"I'm Slow!" andBlock:^{
                [calculator computeFibonnaciNumberVeryVerySlowly:33];
            }] autorelease];
        });

        it(@"should return the running time of the test", ^{
            fastExample.runTime should equal(0);
            slowExample.runTime should equal(0);
            [fastExample runWithDispatcher:dispatcher];
            [slowExample runWithDispatcher:dispatcher];
            fastExample.runTime should be_greater_than(0);
            slowExample.runTime should be_greater_than(0);
            slowExample.runTime should be_greater_than(fastExample.runTime);
        });
    });
});

SPEC_END
