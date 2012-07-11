#import <Cedar/SpecHelper.h>
#import "SimpleIncrementer.h"

SHARED_EXAMPLE_GROUPS_BEGIN(CedarDoubleSharedExamples)

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

sharedExamplesFor(@"a Cedar double", ^(NSDictionary *sharedContext) {
    __block id<CedarDouble, SimpleIncrementer> myDouble;

    beforeEach(^{
        myDouble = [sharedContext objectForKey:@"double"];
    });

    describe(@"#stub_method", ^{
        context(@"with a method name that the stub does not respond to", ^{
            it(@"should raise an exception", PENDING);
        });

        context(@"with a method with no parameters", ^{
            __block Cedar::Doubles::StubbedMethod *stubbed_method_ptr;

            beforeEach(^{
                // This should work.  Thanks for the compiler bug, Apple.
                // Radar #???
//            myDouble.stub_method("value");
                stubbed_method_ptr = &[myDouble stub_method]("value");
            });

            it(@"should record the invocation", ^{
                [myDouble value];
                myDouble should have_received("value");
            });

            context(@"and then stubbed again", ^{
                it(@"should raise an exception", ^{
                    ^{ [myDouble stub_method]("value"); } should raise_exception;
                });
            });

            context(@"with a parameter", ^{
                it(@"should raise an exception", ^{
                    ^{ stubbed_method_ptr->with(1); } should raise_exception;
                });
            });

            context(@"with no return value", ^{
                it(@"should return zero", ^{
                    myDouble.value should equal(0);
                });
            });

            context(@"with a return value of the correct type", ^{
                size_t someArgument = 1;

                beforeEach(^{
                    stubbed_method_ptr->and_return(someArgument);
                });

                it(@"should return the specified return value", ^{
                    myDouble.value should equal(someArgument);
                });
            });

            context(@"with a return value of a type with the wrong binary size", ^{
                int someArgument = 1;

                it(@"should raise an exception", ^{
                    ^{ stubbed_method_ptr->and_return(someArgument); } should raise_exception;
                });
            });

            context(@"with a return value of an inappropriate type", ^{
                it(@"should raise an exception", ^{
                    ^{ stubbed_method_ptr->and_return(@"foo"); } should raise_exception;
                });
            });
        });
    });
});

SHARED_EXAMPLE_GROUPS_END
