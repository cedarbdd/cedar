#import <sstream>
#import "StringifiersBase.h"

namespace Cedar { namespace Matchers { namespace Stringifiers {
    inline NSString * string_for(const CGRect value) {
        return NSStringFromCGRect(value);
    }

    inline NSString * string_for(const CGSize value) {
        return NSStringFromCGSize(value);
    }

    inline NSString * string_for(const CGPoint value) {
        return NSStringFromCGPoint(value);
    }

    inline NSString * string_for(const UIEdgeInsets value) {
        return NSStringFromUIEdgeInsets(value);
    }

    inline NSString * string_for(const CGAffineTransform value) {
        return NSStringFromCGAffineTransform(value);
    }
}}}
