#import "Cedar.h"
#import "SimpleIncrementer.h"

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

        context(@"with a specific argument value", ^{
            context(@"when invoked with a parameter of non-matching value", ^{
                beforeEach(^{
                    myOrdinaryFake stub_method("methodWithNumber1:andNumber2:").with(arg1, arg2).and_return(@3);
                });

                it(@"should raise an exception", ^{
                    ^{ [myOrdinaryFake methodWithNumber1:arg1 andNumber2:arg3]; } should raise_exception.with_reason(@"Wrong arguments supplied to stub");
                });
            });
        });

        context(@"with a nil argument", ^{
            beforeEach(^{
                myOrdinaryFake stub_method("methodWithNumber1:andNumber2:").with(nil, nil);
            });

            context(@"when invoked with a non-nil argument", ^{
                it(@"should raise an exception", ^{
                    ^{ [myOrdinaryFake methodWithNumber1:nil andNumber2:@123]; } should raise_exception.with_reason(@"Wrong arguments supplied to stub");
                });
            });
        });

        context(@"with an argument specified as any instance of a specified class", ^{
            NSNumber *arg = @123;

            beforeEach(^{
                myOrdinaryFake stub_method("methodWithNumber1:andNumber2:").with(any([NSDecimalNumber class]), arg).and_return(@99);
            });

            context(@"when invoked with the incorrect class", ^{
                it(@"should raise an exception", ^{
                    ^{ [myOrdinaryFake methodWithNumber1:@3.14159265359 andNumber2:arg]; } should raise_exception.with_reason(@"Wrong arguments supplied to stub");
                });
            });

            context(@"when invoked with nil", ^{
                it(@"should raise an exception", ^{
                    ^{ [myOrdinaryFake methodWithNumber1:nil andNumber2:arg]; } should raise_exception.with_reason(@"Wrong arguments supplied to stub");
                });
            });
        });

        context(@"with an argument specified as any instance conforming to a specified protocol", ^{
            NSNumber *arg = @123;

            beforeEach(^{
                myOrdinaryFake stub_method("methodWithNumber1:andNumber2:").with(any(@protocol(InheritedProtocol)), arg).and_return(@99);
            });

            context(@"when invoked with the incorrect class", ^{
                it(@"should return 0", ^{
                    ^{ [myOrdinaryFake methodWithNumber1:@3.14159265359 andNumber2:arg]; } should raise_exception.with_reason(@"Wrong arguments supplied to stub");
                });
            });

            context(@"when invoked with nil", ^{
                it(@"should return 0", ^{
                    ^{ [myOrdinaryFake methodWithNumber1:nil andNumber2:arg]; } should raise_exception.with_reason(@"Wrong arguments supplied to stub");
                });
            });
        });
    });
});

SHARED_EXAMPLE_GROUPS_END
