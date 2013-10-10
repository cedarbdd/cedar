#import <Foundation/Foundation.h>
#import "RespondsTo.h"

namespace Cedar { namespace Matchers {

    RespondsTo::RespondsTo(SEL selector)
    : expectedSelectorName_(NSStringFromSelector(selector))
    {}
    
    RespondsTo::RespondsTo(NSString *selectorName)
    : expectedSelectorName_(selectorName)
    {}
    
    RespondsTo::~RespondsTo()
    {}
    
    /*virtual*/ NSString * RespondsTo::failure_message_end() const {
        return [NSString stringWithFormat:@"responds to <%@> selector",
                expectedSelectorName_];
    }
    
    /*virtual*/ bool RespondsTo::matches(const id subject) const
    {
        return [subject respondsToSelector:NSSelectorFromString(expectedSelectorName_)];
    }
}}