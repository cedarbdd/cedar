#import <UIKit/UIKit.h>
#import "Cedar.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CDRSpyiOSSpec)

describe(@"CDRSpy on iOS", ^{

    context(@"when spying upon UITextField", ^{
        __block UITextField *textField;

        beforeEach(^{
            textField = [[[UITextField alloc] init] autorelease];
            spy_on(textField);
        });

        it(@"should handle isSecureTextEntry message which is proxied weirdly on iOS =< 6.1", ^{
            [textField isSecureTextEntry];
        });
    });
});

SPEC_END
