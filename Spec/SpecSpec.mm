#if TARGET_OS_IPHONE
// Normally you would include this file out of the framework.  However, we're
// testing the framework here, so including the file from the framework will
// conflict with the compiler attempting to include the file from the project.
#import "CDRSpecHelper.h"
#else
#import <Cedar/CDRSpecHelper.h>
#endif

#import "CDRSpecFailure.h"

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
    
    invariant(@"an invariant run in multiple places", ^{
        //    NSLog(@"=====================> Invariant was run here.");
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
        
        it(@"should run the invariant below here", ^{
            //    NSLog(@"vvvvvvvvvvvvvvvvvvvvvv Invariant below");
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
        
        context(@"a doubly nested spec", ^{
            it(@"should also run", ^{
                //      NSLog(@"=====================> Nested spec");
            });
            
            it(@"should run the invariant below here", ^{
                //    NSLog(@"vvvvvvvvvvvvvvvvvvvvvv Invariant below");
            });
        });
        
        it(@"should run the invariant below here", ^{
            //    NSLog(@"vvvvvvvvvvvvvvvvvvvvvv Invariant below");
        });
    });

    it(@"should run", ^{
        //    NSLog(@"=====================> Spec");
    });
    
    it(@"should run the invariant below here", ^{
        //    NSLog(@"vvvvvvvvvvvvvvvvvvvvvv Invariant below");
    });

    it(@"should be pending", PENDING);
    it(@"should also be pending", nil);
    xit(@"should also be pending (xit)", ^{});

    describe(@"invariants", ^{
        it_should_always(@"be pending", PENDING);
        it_should_always(@"also be pending", nil);
        xit_should_always(@"also be pending (xit_should_always)", ^{});
        
        it(@"should force invariants", ^{});
    });
    
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

        expect(globalValue__).to(be_nil);
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

describe(@"an invariant", ^{
    __block NSInteger x;
    __block NSInteger y;
    __block BOOL ran;

    beforeEach(^{
        x = 0;
        y = 0;
        ran = NO;
    });
    
    invariant(@"invariant equates the two variables", ^{
        expect(x).to(equal(y));
        ran = YES;
    });
    
    context(@"in a context block", ^{
        beforeEach(^{
            x = 5;
            y = 5;
        });
        
        context(@"in a nested context block", ^{
            beforeEach(^{
                x = -2;
                y = -2;
            });
            
            it(@"force the invariant", ^{expect(true).to(be_truthy());});
            
            afterEach(^{
                it(@"should run the invariant", ^{
                    expect(ran).to(be_truthy());
                });
            });
        });
        
        afterEach(^{
            it(@"should run the invariant", ^{
                expect(ran).to(be_truthy());
            });
        });
    });
    
    context(@"in a pending context block should be pending", ^{});
    
    afterEach(^{
        it(@"should run the invariant", ^{
            expect(ran).to(be_truthy());
        });
    });
});

describe(@"a failing invariant", ^{
    __block BOOL tried;
    __block BOOL ran;

    beforeEach(^{
        tried = NO;
        ran = NO;
    });
    
    invariant(@"invariant tries to do the impossible", ^{
        expectFailure(^{
            tried = YES;
            expect(true).to(be_falsy());
            ran = YES;
        });
    });
    
    it(@"force the invariant", ^{expect(true).to(be_truthy());});
    
    afterEach(^{
        it(@"should run the invariant", ^{
            expect(tried).to(be_truthy());
        });
        
        it(@"should not complete running the invariant", ^{
            expect(ran).to(be_falsy());
        });
    });
});

describe(@"an invariant and a subject action block", ^{
    __block NSInteger x;
    __block NSInteger y;
    __block BOOL ran;
    
    beforeEach(^{
        x = 5;
        y = 0;
        ran = NO;
    });
    
    invariant(@"invariant equates the two variables", ^{
        expect(x).to(equal(y));
        ran = YES;
    });
    
    subjectAction(^{ y = 5; });
    
    context(@"in a context block", ^{
        beforeEach(^{
            x = 5;
            y = 0;
        });
        
        context(@"in a nested context block", ^{
            beforeEach(^{
                x = 5;
                y = 0;
            });
            
            it(@"force the invariant", ^{expect(true).to(be_truthy());});
            
            afterEach(^{
                it(@"should run the invariant after the subject action", ^{
                    expect(ran).to(be_truthy());
                });
            });
        });
        
        afterEach(^{
            it(@"should run the invariant after the subject action", ^{
                expect(ran).to(be_truthy());
            });
        });
    });
    
    context(@"in a pending context block should be pending", ^{});
    
    afterEach(^{
        it(@"should run the invariant after the subject action", ^{
            expect(ran).to(be_truthy());
        });
    });
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
