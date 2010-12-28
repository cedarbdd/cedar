#define HC_SHORTHAND
#if TARGET_OS_IPHONE
// Normally you would include this file out of the framework.  However, we're
// testing the framework here, so including the file from the framework will
// conflict with the compiler attempting to include the file from the project.
#import "SpecHelper.h"
#import "OCMock.h"
#import "OCHamcrest.h"
#else
#import <Cedar/SpecHelper.h>
#import <OCMock/OCMock.h>
#import <OCHamcrest/OCHamcrest.h>
#endif

#import "CDRExample.h"
#import "CDRExampleGroup.h"

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
            assertThat([example parent], nilValue());
        });

        it(@"should return just its own text", ^{
            assertThat([example fullText], equalTo(exampleText));
        });
    });

    describe(@"with a parent", ^{
        __block CDRExampleGroup *root;
        __block CDRExampleGroup *group;
        NSString *groupText = @"Parent!";

        beforeEach(^{
            root  = [[CDRExampleGroup alloc] initWithText:@"wibble wobble"];
            group = [[CDRExampleGroup alloc] initWithText:groupText];
            [group add:example];
            [root add:group];
            assertThat([example parent], isNot(nilValue()));
        });

        afterEach(^{
            [group release];
            [root release];
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
                
                [root add:rootGroup];
            });

            afterEach(^{
                [rootGroup release];
            });

            it(@"should include the text from all parents, pre-pended in the appopriate order", ^{
                assertThat([example fullText], equalTo([NSString stringWithFormat:@"%@ %@ %@", rootGroupText, groupText, exampleText]));
            });
        });
    });

    describe(@"with a root group as a parent", ^{
        __block CDRExampleGroup *rootGroup;

        beforeEach(^{
            rootGroup = [[CDRExampleGroup alloc] initWithText:@"wibble wobble"];
            [rootGroup add:example];
            assertThat([example parent], isNot(nilValue()));
        });

        it(@"should not include its parent's text", ^{
            assertThat([example fullText], equalTo([example text]));
        });
    });
} copy];

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
                [example run];
            });

            it(@"should be CDRExampleStatePassed", ^{
                assertThatInt([example state], equalToInt(CDRExampleStatePassed));
            });
        });

        describe(@"for an example that has run and failed", ^{
            beforeEach(^{
                [example release];
                example = [[CDRExample alloc] initWithText:@"I should fail" andBlock:^{ fail(@"fail"); }];
                [example run];
            });

            it(@"should be CDRExampleStateFailed", ^{
                assertThatInt([example state], equalToInt(CDRExampleStateFailed));
            });
        });

        describe(@"for an example that has run and thrown an NSException", ^{
            beforeEach(^{
                [example release];
                example = [[CDRExample alloc] initWithText:@"I should throw an NSException" andBlock:^{ [[NSException exceptionWithName:@"name" reason:@"reason" userInfo:nil] raise]; }];
                [example run];
            });

            it(@"should be CDRExceptionStateError", ^{
                assertThatInt([example state], equalToInt(CDRExampleStateError));
            });
        });

        describe(@"for an example that has run and thrown something other than an NSException", ^{
            beforeEach(^{
                [example release];
                example = [[CDRExample alloc] initWithText:@"I should throw some nonsense" andBlock:^{ @throw @"Some nonsense"; }];
                [example run];
            });

            it(@"should be CDRExceptionStateError", ^{
                assertThatInt([example state], equalToInt(CDRExampleStateError));
            });
        });

        describe(@"for a pending example", ^{
            beforeEach(^{
                [example release];
                example = [[CDRExample alloc] initWithText:@"I should be pending" andBlock:PENDING];
                [example run];
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
                [example run];
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
                [example run];
                assertThatInt([example state], equalToInt(CDRExampleStatePassed));
            });

            it(@"should return 1", ^{
                assertThatFloat([example progress], equalToFloat(1.0));
            });
        });
    });

    describe(@"fullText", ^{
        __block NSMutableDictionary *sharedExampleContext = [[NSMutableDictionary alloc] init];

        beforeEach(^{
            [sharedExampleContext setObject:example forKey:@"example"];
            [sharedExampleContext setObject:exampleText forKey:@"exampleText"];
        });

        sharedExampleMethod(sharedExampleContext);
    });

    describe(@"message", ^{
        describe(@"for an incomplete example", ^{
            beforeEach(^{
                assertThatInt([example state], equalToInt(CDRExampleStateIncomplete));
            });

            it(@"should return an empty string", ^{
                assertThat([example message], equalTo(@""));
            });
        });

        describe(@"for a passing example", ^{
            beforeEach(^{
                [example release];
                example = [[CDRExample alloc] initWithText:@"I should pass" andBlock:^{}];
                [example run];
            });

            it(@"should return an empty string", ^{
                assertThat([example message], equalTo(@""));
            });
        });

        describe(@"for a pending example", ^{
            beforeEach(^{
                [example release];
                example = [[CDRExample alloc] initWithText:@"I should pend" andBlock:nil];
                [example run];
            });

            it(@"should return an empty string", ^{
                assertThat([example message], equalTo(@""));
            });
        });

        describe(@"for a failing example", ^{
            __block NSString *failureMessage = @"I should fail";

            beforeEach(^{
                [example release];
                example = [[CDRExample alloc] initWithText:@"I should fail" andBlock:^{[[CDRSpecFailure specFailureWithReason:failureMessage] raise];}];
                [example run];
            });

            it(@"should return the failure message", ^{
                assertThat([example message], equalTo(failureMessage));
            });
        });

        describe(@"for an example that throws an NSException", ^{
            __block NSException *exception;

            beforeEach(^{
                exception = [NSException exceptionWithName:@"name" reason:@"reason" userInfo:nil];

                [example release];
                example = [[CDRExample alloc] initWithText:@"I should throw an exception" andBlock:^{ [exception raise]; }];
                [example run];
            });

            it(@"should return the description of the exception", ^{
                assertThat([example message], equalTo([exception description]));
            });
        });

        describe(@"for an example that throws a non-NSException", ^{
            __block NSString *failureMessage = @"wibble wobble";

            beforeEach(^{
                [example release];
                example = [[CDRExample alloc] initWithText:@"I should throw an exception" andBlock:^{ @throw failureMessage; }];
                [example run];
            });

            it(@"should return the description of whatever was thrown", ^{
                assertThat([example message], equalTo(failureMessage));
            });
        });
    });
});

SPEC_END
