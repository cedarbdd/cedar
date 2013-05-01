#import <Cedar/SpecHelper.h>
#import "SimpleIncrementer.h"
#import "StubbedMethod.h"

SHARED_EXAMPLE_GROUPS_BEGIN(CedarNiceFakeSharedExamples)

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;
using namespace Cedar::Doubles::Arguments;

sharedExamplesFor(@"a Cedar nice fake", ^(NSDictionary *sharedContext) {
    __block id<CedarDouble, SimpleIncrementer> myNiceFake;

    beforeEach(^{
        myNiceFake = [sharedContext objectForKey:@"double"];
    });

    context(@"of the correct types", ^{
        NSNumber *arg1 = @1;
        NSNumber *arg2 = @2;
        NSNumber *arg3 = @3;
        NSNumber *returnValue = @4;


        context(@"with an argument specified as anything", ^{
            context(@"when stubbing a method using .with().and_with()", ^{
                beforeEach(^{
                    myNiceFake stub_method("methodWithNumber1:andNumber2:").with(anything).and_with(arg2).and_return(returnValue);
                });

                it(@"should still require the non-'anything' argument to match", ^{
                    [myNiceFake methodWithNumber1:@8 andNumber2:arg2] should equal(returnValue);
                });

                it(@"should return nil if the non-'anything' argument does not match", ^{
                    expect([myNiceFake methodWithNumber1:@8 andNumber2:arg3]).to(be_nil);
                });
            });

            context(@"when stubbing a method using .with(varargs)", ^{
                beforeEach(^{
                    myNiceFake stub_method("methodWithNumber1:andNumber2:").with(anything, arg2).and_return(returnValue);
                });

                it(@"should still require the non-'anything' argument to match", ^{
                    [myNiceFake methodWithNumber1:@8 andNumber2:arg2] should equal(returnValue);
                });

                it(@"should return nil if the non-'anything' argument does not match", ^{
                    expect([myNiceFake methodWithNumber1:@8 andNumber2:arg3]).to(be_nil);
                });
            });
        });

        context(@"when invoked with a parameter of non-matching value", ^{
            context(@"when stubbing a method using .with().and_with()", ^{
                beforeEach(^{
                    myNiceFake stub_method("methodWithNumber1:andNumber2:").with(arg1).and_with(arg2).and_return(returnValue);
                });

                it(@"should not raise an exception", ^{
                    ^{ [myNiceFake methodWithNumber1:arg1 andNumber2:arg3]; } should_not raise_exception;
                });

                it(@"should return nil", ^{
                    expect([myNiceFake methodWithNumber1:arg1 andNumber2:arg3]).to(be_nil);
                });
            });

            context(@"when stubbing a method using .with(varargs)", ^{
                beforeEach(^{
                    myNiceFake stub_method("methodWithNumber1:andNumber2:").with(arg1, arg2).and_return(returnValue);
                });

                it(@"should not raise an exception", ^{
                    ^{ expect([myNiceFake methodWithNumber1:arg1 andNumber2:arg3]); } should_not raise_exception;
                });

                it(@"should return nil", ^{
                    expect([myNiceFake methodWithNumber1:arg1 andNumber2:arg3]).to(be_nil);
                });
            });
        });
    });
});

SHARED_EXAMPLE_GROUPS_END
