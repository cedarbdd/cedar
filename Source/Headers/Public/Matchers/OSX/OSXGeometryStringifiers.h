#import "StringifiersBase.h"

#ifdef __cplusplus

#import <sstream>

namespace Cedar { namespace Matchers { namespace Stringifiers {
    inline NSString * string_for(const CGRect value) {
        return NSStringFromRect(value);
    }

    inline NSString * string_for(const CGSize value) {
        return NSStringFromSize(value);
    }

    inline NSString * string_for(const CGPoint value) {
        return NSStringFromPoint(value);
    }

    inline NSString * string_for(const CGAffineTransform value) {
        return [NSString stringWithFormat:@"[%g, %g, %g, %g, %g, %g]",
                value.a, value.b, value.c, value.d, value.tx, value.ty];
    }
}}}

#endif // __cplusplus
