// CDRSpecHelper.h should only be imported into this target from the iOS framework
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(iOSFrameworkSpecs)

describe(@"Cedar-iOS", ^{
    __block NSObject *object;

    beforeEach(^{
        object = [[NSObject alloc] init];
    });

    it(@"should allow assertions", ^{
        object should_not be_nil;
        object should_not be_same_instance_as([[NSObject alloc] init]);
    });
});

SPEC_END
