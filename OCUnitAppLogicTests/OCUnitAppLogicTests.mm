#import "SpecHelper.h"
#import "DummyModel.h" // should be included in OCUnitAppLogicTests target

using namespace Cedar::Matchers;

SPEC_BEGIN(OCUnitAppLogicTests)

describe(@"A spec file testing domain classes", ^{
    it(@"should run", ^{
        expect([DummyModel class]).to(equal([DummyModel class]));
    });
});

SPEC_END
