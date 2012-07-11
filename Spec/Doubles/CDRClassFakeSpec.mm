#import <Cedar/SpecHelper.h>
#import "SimpleIncrementer.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CDRClassFakeSpec)

describe(@"fake (class)", ^{
    __block SimpleIncrementer<CedarDouble> *my_fake;

    beforeEach(^{
        my_fake = fake([SimpleIncrementer class]);

        [[SpecHelper specHelper].sharedExampleContext setObject:my_fake forKey:@"double"];
    });

    itShouldBehaveLike(@"a Cedar double");

    context(@"when calling a method which has not been stubbed", ^{
        it(@"should raise an exception", ^{
            ^{ [my_fake value]; } should raise_exception;
        });
    });
    
    describe(@"#respondsToSelector:", ^{
        context(@"when an instance method is defined", ^{
            it(@"should return true", ^{
                [my_fake respondsToSelector:@selector(value)] should be_truthy;
            });
        });
        
        context(@"when an instance method is not defined", ^{
            it(@"should return false", ^{
                [my_fake respondsToSelector:@selector(wibble_wobble)] should_not be_truthy;
            });
        });
    });

    describe(@"#description", ^{
        it(@"should return the description of the faked class", ^{
            my_fake.description should contain(@"SimpleIncrementer");
        });
    });
});

SPEC_END
