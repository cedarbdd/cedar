using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ExampleSpec)

describe(@"Why are all of my tests red???", ^{

    it(@"should fail miserable", ^{
      NO should be_truthy;
    });

});

SPEC_END

