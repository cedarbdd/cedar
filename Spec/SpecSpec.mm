#import "Cedar.h"

using namespace Cedar::Matchers;

void expectFailure(CDRSpecBlock block) {
    @try {
        block();
    }
    @catch (CDRSpecFailure *) {
        return;
    }

    fail(@"Expectation should have failed.");
}

static NSString *globalValue__;

SPEC_BEGIN(SpecSpec)

describe(@"Spec", ^{
    beforeEach(^{
        //    NSLog(@"=====================> I should run before all specs.");
    });

    afterEach(^{
        //    NSLog(@"=====================> I should run after all specs.");
    });

    describe(@"a nested spec", ^{
        beforeEach(^{
            //      NSLog(@"=====================> I should run only before the nested specs.");
        });

        afterEach(^{
            //      NSLog(@"=====================> I should run only after the nested specs.");
        });

        it(@"should also run", ^{
            //      NSLog(@"=====================> Nested spec");
        });

        it(@"should also also run", ^{
            //      NSLog(@"=====================> Another nested spec");
        });
    });

    context(@"a nested spec (context)", ^{
        beforeEach(^{
          //      NSLog(@"=====================> I should run only before the nested specs.");
        });

        afterEach(^{
          //      NSLog(@"=====================> I should run only after the nested specs.");
        });

        it(@"should also run", ^{
          //      NSLog(@"=====================> Nested spec");
        });

        it(@"should also also run", ^{
          //      NSLog(@"=====================> Another nested spec");
        });
    });

    it(@"should run", ^{
        //    NSLog(@"=====================> Spec");
    });

    it(@"should be pending", PENDING);
    it(@"should also be pending", nil);
    xit(@"should also be pending (xit)", ^{});

    describe(@"described specs should be pending", PENDING);
    describe(@"described specs should also be pending", nil);
    xdescribe(@"xdescribed specs should be pending", ^{});

    context(@"contexted specs should be pending", PENDING);
    context(@"contexted specs should also be pending", nil);
    xcontext(@"xcontexted specs should be pending", ^{});

    describe(@"empty describe blocks should be pending", ^{});
    context(@"empty context blocks should be pending", ^{});
});

describe(@"The spec failure exception", ^{
//    it(@"should generate a spec failure", ^{
//        [[CDRSpecFailure specFailureWithReason:@"'cuz"] raise];
//    });
//
//    it(@"should throw exception", ^{
//        [[NSException exceptionWithName:@"exception name" reason:@"exception reason" userInfo:nil] raise];
//    });
});

describe(@"subjectAction", ^{
    __block int value;

    subjectAction(^{ value = 5; });

    beforeEach(^{
        value = 100;
    });

    it(@"should run after the beforeEach", ^{
        value should equal(5);
    });

    describe(@"in a nested describe block", ^{
        beforeEach(^{
            value = 200;
        });

        it(@"should run after all the beforeEach blocks", ^{
            value should equal(5);
        });
    });
});

describe(@"Matchers", ^{
    describe(@"equality", ^{
        describe(@"with Objective-C types", ^{
            __block NSNumber *expectedNumber;

            beforeEach(^{
                expectedNumber = [NSNumber numberWithInt:1];
            });

            it(@"should succeed when the two objects are equal", ^{
                expect(expectedNumber).to(equal([NSNumber numberWithInt:1]));
            });

            it(@"should fail when the two objects are not equal", ^{
                expectFailure(^{
                    expect(expectedNumber).to(equal([NSNumber numberWithInt:2]));
                });
            });
        });

        describe(@"with built-in types", ^{
            __block int expectedValue = 1;

            beforeEach(^{
                expectedValue = 1;
            });

            it(@"should succeed when the two objects are equal", ^{
                expect(expectedValue).to(equal(1));
            });

            it(@"should succeed with different types that are comparable", ^{
                expect(expectedValue).to(equal(1.0));
            });

            it(@"should fail when the objects are not equal", ^{
                expectFailure(^{
                    expect(expectedValue).to(equal(2));
                });
            });
        });
    });

    describe(@"that fail outside of an `it` block", ^{
        __block NSException *caughtException = nil;

        @try {
            describe(@"performing the assertion", ^{
                1 should equal(2);
            });
        }
        @catch (NSException *exception) {
            caughtException = [exception retain];
        }

        it(@"should raise an exception with a helpful message", ^{
            caughtException.name should equal(NSInternalInconsistencyException);
            caughtException.reason should contain(@"Caught a spec failure before the specs began to run. Did you forget to put your assertion into an `it` block?. The failure was:");
        });
    });
});

describe(@"a describe block", ^{
    beforeEach(^{
        globalValue__ = nil;
    });

    describe(@"that contains a beforeEach in a shared example group", ^{
        itShouldBehaveLike(@"a describe context that contains a beforeEach in a shared example group");

        it(@"should not run the shared beforeEach before specs outside the shared example group", ^{
            expect(globalValue__).to(be_nil());
        });
    });

    describe(@"that passes a value to the shared example context", ^{
        beforeEach(^{
            globalValue__ = @"something";
            [[CDRSpecHelper specHelper].sharedExampleContext setObject:globalValue__ forKey:@"value"];
        });

        itShouldBehaveLike(@"a shared example group that receives a value in the context");
    });

    describe(@"that passes a value in-line to the shared example context", ^{
        beforeEach(^{
            globalValue__ = @"something";
        });

        itShouldBehaveLike(@"a shared example group that receives a value in the context", ^(NSMutableDictionary *context) {
            context[@"value"] = globalValue__;
        });
    });

    itShouldBehaveLike(@"a shared example group that contains a failing spec");
});

describe(@"a describe block that tries to include a shared example group that doesn't exist", ^{
    @try {
        itShouldBehaveLike(@"a unicorn");
    } @catch (NSException *) {
        return;
    }
    [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Should have thrown an exception" userInfo:nil];
});

SPEC_END


SHARED_EXAMPLE_GROUPS_BEGIN(Specs)

sharedExamplesFor(@"a describe context that contains a beforeEach in a shared example group", ^(NSDictionary *context) {
    beforeEach(^{
        expect([[CDRSpecHelper specHelper].sharedExampleContext count]).to(equal(0));
        globalValue__ = [NSString string];
    });

    it(@"should run the shared beforeEach before specs inside the shared example group", ^{
        expect(globalValue__).to_not(be_nil());
    });
});

sharedExamplesFor(@"a shared example group that receives a value in the context", ^(NSDictionary *context) {
    it(@"should receive the values set in the global shared example context", ^{
        expect([context objectForKey:@"value"]).to(equal(globalValue__));
    });
});

sharedExamplesFor(@"a shared example group that contains a failing spec", ^(NSDictionary *context) {
    it(@"should fail in the expected fashion", ^{
        expectFailure(^{
            expect(@"wibble").to(equal(@"wobble"));
        });
    });
});

SHARED_EXAMPLE_GROUPS_END
