#import "Cedar.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CedarApplicationDelegateSpec)

describe(@"CedarApplicationDelegate", ^{
    __block CedarApplicationDelegate *delegate;

    beforeEach(^{
        delegate = [[[CedarApplicationDelegate alloc] init] autorelease];
    });

    describe(@"-window", ^{
        it(@"should raise an educational exception", ^{
            ^{ [delegate window]; } should raise_exception.with_reason(@"This Cedar iOS spec suite is run with the CedarApplicationDelegate.  If your code needs the UIApplicationDelegate's window, you should stub this method to return an appropriate window.");
        });
    });
});

SPEC_END
