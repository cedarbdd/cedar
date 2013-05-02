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

    describe(@"method stubbing", ^{
        NSNumber *arg1 = @1;
        NSNumber *arg2 = @2;
        NSNumber *arg3 = @3;

        context(@"with a specific argument value", ^{
            context(@"when invoked with a parameter of non-matching value", ^{
                beforeEach(^{
                    myNiceFake stub_method("methodWithNumber1:andNumber2:").with(arg1, arg2).and_return(@4);
                });

                it(@"should not raise an exception", ^{
                    ^{ [myNiceFake methodWithNumber1:arg1 andNumber2:arg3]; } should_not raise_exception;
                });

                it(@"should return nil", ^{
                    [myNiceFake methodWithNumber1:arg1 andNumber2:arg3] should be_nil;
                });
            });
        });

        context(@"with a nil argument", ^{
            beforeEach(^{
                myNiceFake stub_method("methodWithNumber1:andNumber2:").with(nil, nil);
            });

            context(@"when invoked with a non-nil argument", ^{
                it(@"should return nil", ^{
                    [myNiceFake methodWithNumber1:nil andNumber2:@123] should be_nil;
                });
            });
        });

        context(@"with an argument specified as any instance of a specified class", ^{
            NSNumber *arg = @123;

            beforeEach(^{
                myNiceFake stub_method("methodWithNumber1:andNumber2:").with(any([NSDecimalNumber class]), arg).and_return(@99);
            });

            context(@"when invoked with the incorrect class", ^{
                it(@"should return 0", ^{
                    [myNiceFake methodWithNumber1:@3.14159265359 andNumber2:arg] should equal(0);
                });
            });

            context(@"when invoked with nil", ^{
                it(@"should return 0", ^{
                    [myNiceFake methodWithNumber1:nil andNumber2:arg] should equal(0);
                });
            });
        });
    });
});

SHARED_EXAMPLE_GROUPS_END
