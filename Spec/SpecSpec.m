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

void expectFailure(CDRSpecBlock block) {
    @try {
        block();
    }
    @catch (CDRSpecFailure *) {
        return;
    }

    fail(@"equality expectation should have failed.");
}

static NSString *globalValue__;

SPEC_BEGIN(SpecSpec)

describe(@"Spec", ^ {
    beforeEach(^ {
        //    NSLog(@"=====================> I should run before all specs.");
    });

    afterEach(^{
        //    NSLog(@"=====================> I should run after all specs.");
    });

    describe(@"a nested spec", ^ {
        beforeEach(^ {
            //      NSLog(@"=====================> I should run only before the nested specs.");
        });

        afterEach(^ {
            //      NSLog(@"=====================> I should run only after the nested specs.");
        });

        it(@"should also run", ^ {
            //      NSLog(@"=====================> Nested spec");
        });

        it(@"should also also run", ^ {
            //      NSLog(@"=====================> Another nested spec");
        });
    });

    it(@"should run", ^ {
        //    NSLog(@"=====================> Spec");
    });

    it(@"should be pending", PENDING);
    it(@"should also be pending", nil);
});

describe(@"The spec failure exception", ^{
//    it(@"should generate a spec failure", ^ {
//        [[CDRSpecFailure specFailureWithReason:@"'cuz"] raise];
//    });
//
//    it(@"should throw exception", ^{
//        [[NSException exceptionWithName:@"exception name" reason:@"exception reason" userInfo:nil] raise];
//    });
});

describe(@"Hamcrest matchers", ^{
    describe(@"equality", ^{
        describe(@"with Objective-C types", ^{
            __block NSNumber *expectedNumber;

            beforeEach(^{
                expectedNumber = [NSNumber numberWithInt:1];
            });

            it(@"should succeed when the two objects are equal", ^{
                assertThat(expectedNumber, equalTo([NSNumber numberWithInt:1]));
            });

            it(@"should fail when the two objects are not equal", ^{
                expectFailure(^{
                    assertThat(expectedNumber, equalTo([NSNumber numberWithInt:2]));
                });
            });
        });

        describe(@"with built-in types", ^{
            __block int expectedValue = 1;

            beforeEach(^{
                expectedValue = 1;
            });

            it(@"should succeed when the two objects are equal", ^{
                assertThatInt(expectedValue, is(equalToInt(1)));
            });

            it(@"should succeed with different types that are comparable", ^{
                assertThatInt(expectedValue, is(equalToFloat(1.0)));
            });

            it(@"should fail when the objects are not equal", ^{
                expectFailure(^{
                    assertThatInt(expectedValue, is(equalToInt(2)));
                });
            });
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
            assertThat(globalValue__, nilValue());
        });
    });

    describe(@"that sets a value in the global shared example context", ^{
        beforeEach(^{
            globalValue__ = @"something";
            [[SpecHelper specHelper].sharedExampleContext setObject:globalValue__ forKey:@"value"];
        });
    });
});

SPEC_END


SHARED_EXAMPLE_GROUPS_BEGIN(Specs)

sharedExamplesFor(@"a describe context that contains a beforeEach in a shared example group", ^(NSDictionary *context) {
    beforeEach(^{
        assertThatInt([[SpecHelper specHelper].sharedExampleContext count], equalToInt(0));
        globalValue__ = [NSString string];
    });

    it(@"should run the shared beforeEach before specs inside the shared example group", ^{
        assertThat(globalValue__, notNilValue());
    });
});

sharedExamplesFor(@"a shared example group that receives a value in the context", ^(NSDictionary *context) {
    it(@"should receive the values set in the global shared example context", ^{
        assertThat([context objectForKey:@"value"], equalTo(globalValue__));
    });
});

SHARED_EXAMPLE_GROUPS_END
