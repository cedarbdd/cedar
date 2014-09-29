#import <Foundation/Foundation.h>
#import "RespondTo.h"

namespace Cedar { namespace Matchers { namespace Private {

    RespondTo::RespondTo(SEL selector)
    : expectedSelectorName_([NSStringFromSelector(selector) UTF8String]) {}

    RespondTo::RespondTo(const char *selectorName)
    : expectedSelectorName_(selectorName) {}

    RespondTo::~RespondTo() {}

    /*virtual*/ NSString *RespondTo::failure_message_end() const {
        return [NSString stringWithFormat:@"respond to <%@> selector",
                @(expectedSelectorName_)];
    }

    /*virtual*/ bool RespondTo::matches(const id subject) const {
        return [subject respondsToSelector:NSSelectorFromString(@(expectedSelectorName_))];
    }
}}}
