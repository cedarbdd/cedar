#import "SpecHelper.h"

SPEC_BEGIN(SlowSpec)

describe(@"Really slow specs", ^{
    it(@"should take a long time", ^{
        sleep(2);
    });
});

SPEC_END
