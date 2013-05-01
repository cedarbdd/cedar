#import <Cedar/SpecHelper.h>
#import "SimpleIncrementer.h"
#import "StubbedMethod.h"

SHARED_EXAMPLE_GROUPS_BEGIN(CedarOrdinaryFakeSharedExamples)

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;
using namespace Cedar::Doubles::Arguments;

sharedExamplesFor(@"a Cedar ordinary fake", ^(NSDictionary *sharedContext) {
    __block id<CedarDouble, SimpleIncrementer> myOrdinaryFake;

    beforeEach(^{
        myOrdinaryFake = [sharedContext objectForKey:@"double"];
    });

    context(@"of the correct types", ^{
        NSNumber *arg1 = @1;
        NSNumber *arg2 = @2;
        NSNumber *arg3 = @3;
        NSNumber *returnValue = @3;

        context(@"when invoked with a parameter of non-matching value", ^{
            context(@"when stubbing a method using .with().and_with()", ^{
                beforeEach(^{
                    myOrdinaryFake stub_method("methodWithNumber1:andNumber2:").with(arg1).and_with(arg2).and_return(returnValue);
                });

                it(@"should raise an exception", ^{
                    ^{ [myOrdinaryFake methodWithNumber1:arg1 andNumber2:arg3]; } should raise_exception.with_reason(@"Wrong arguments supplied to stub");
                });
            });

            context(@"when stubbing a method using .with(varargs)", ^{
                beforeEach(^{
                    myOrdinaryFake stub_method("methodWithNumber1:andNumber2:").with(arg1, arg2).and_return(returnValue);
                });

                it(@"should raise an exception", ^{
                    ^{ expect([myOrdinaryFake methodWithNumber1:arg1 andNumber2:arg3]); } should raise_exception.with_reason(@"Wrong arguments supplied to stub");
                });
            });
        });

        context(@"with an argument specified as anything", ^{
            context(@"when stubbing a method using .with().and_with()", ^{
                NSNumber *returnValue = @456;

                beforeEach(^{
                    myOrdinaryFake stub_method("methodWithNumber1:andNumber2:").with(anything).and_with(arg2).and_return(returnValue);
                });

                it(@"should still require the non-'anything' argument to match", ^{
                    [myOrdinaryFake methodWithNumber1:@8 andNumber2:arg2] should equal(returnValue);
                });

                it(@"should raise an exception if the non-'anything' argument does not match", ^{
                    ^{ [myOrdinaryFake methodWithNumber1:@8 andNumber2:arg3]; } should raise_exception.with_reason(@"Wrong arguments supplied to stub");
                });
            });

            context(@"when stubbing a method using .with(varargs)", ^{
                beforeEach(^{
                    myOrdinaryFake stub_method("methodWithNumber1:andNumber2:").with(anything, arg2).and_return(returnValue);
                });

                it(@"should still require the non-'anything' argument to match", ^{
                    [myOrdinaryFake methodWithNumber1:@8 andNumber2:arg2] should equal(returnValue);
                });

                it(@"should raise an exception if the non-'anything' argument does not match", ^{
                    ^{ [myOrdinaryFake methodWithNumber1:@8 andNumber2:arg3]; } should raise_exception.with_reason(@"Wrong arguments supplied to stub");
                });
            });
        });
    });
});

SHARED_EXAMPLE_GROUPS_END
