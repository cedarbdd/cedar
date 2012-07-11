#import <Cedar/SpecHelper.h>
#import "SimpleIncrementer.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CDRClassFakeSpec)

describe(@"create_double", ^{
    __block SimpleIncrementer<CedarDouble> *my_fake;

    beforeEach(^{
        my_fake = fake([SimpleIncrementer class]);

        [[SpecHelper specHelper].sharedExampleContext setObject:my_fake forKey:@"double"];
    });

    itShouldBehaveLike(@"a Cedar double");

    it(@"should respond to instance methods for the class", ^{
        [my_fake respondsToSelector:@selector(value)] should be_truthy;
    });

    context(@"when calling a method which has not been stubbed", ^{
        it(@"should raise an exception", ^{
            ^{ [my_fake value]; } should raise_exception;
        });
    });

    describe(@"#description", ^{
        it(@"should return the description of the faked class", ^{
            my_fake.description should contain(@"SimpleIncrementer");
        });
    });
});

SPEC_END
