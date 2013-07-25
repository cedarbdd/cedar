#import "AppDelegate.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ExampleSpec)

describe(@"Referencing of AppDelegate", ^{

    it(@"should not fail", ^{
        AppDelegate *delegate = [[AppDelegate alloc] init];
    });

});

SPEC_END

