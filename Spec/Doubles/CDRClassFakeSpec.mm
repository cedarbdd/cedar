#import <Cedar/SpecHelper.h>
#import "SimpleIncrementer.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CDRClassFakeSpec)

describe(@"create_double", ^{
    __block SimpleIncrementer<CedarDouble> *my_fake;

    beforeEach(^{
        my_fake = fake([SimpleIncrementer class]);
    });

    // TODO: this
//    itShouldBehaveLike(@"a Cedar double");

    it(@"should respond to instance methods for the class", ^{
        [my_fake respondsToSelector:@selector(value)] should be_truthy;
    });

    context(@"when increment has not been stubbed", ^{
        it(@"should raise an exception with a reasonably helpful error message", ^{
            ^{ [my_fake value]; } should raise_exception;
        });
    });

    it(@"should return the description of the faked class", ^{
        my_fake.description should contain(@"SimpleIncrementer");
    });

    context(@"when 'value' has been stubbed", ^{
        __block StubbedMethod *stubbed_method_ptr;

        beforeEach(^{
            stubbed_method_ptr = &[my_fake stub_method]("value");
        });

        it(@"should still record the invocation", ^{
            [my_fake value];
            my_fake should have_received("value");
        });

        context(@"and then stubbed again", ^{
            it(@"should raise an exception", ^{
                ^{ [my_fake stub_method]("value"); } should raise_exception;
            });
        });

        context(@"with a parameter", ^{
            it(@"should raise an exception", ^{
                ^{ stubbed_method_ptr->with(1); } should raise_exception;
            });
        });

        context(@"with no return value", ^{
            it(@"should return zero", ^{
                my_fake.value should equal(0);
            });
        });

        context(@"with a return value of the correct type", ^{
            size_t someArgument = 1;

            beforeEach(^{
                stubbed_method_ptr->and_return(someArgument);
            });

            it(@"should return the specified return value", ^{
                my_fake.value should equal(someArgument);
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

SPEC_END
