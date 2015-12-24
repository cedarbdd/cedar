#import "ComparatorsBase.h"
#import "OSXGeometryStringifiers.h"

#ifdef __cplusplus

namespace Cedar { namespace Matchers { namespace Comparators {
    template<typename U>
    bool compare_equal(CGRect const actualValue, const U & expectedValue) {
        return CGRectEqualToRect(actualValue, expectedValue);
    }

    template<typename U>
    bool compare_equal(CGSize const actualValue, const U & expectedValue) {
        return CGSizeEqualToSize(actualValue, expectedValue);
    }

    template<typename U>
    bool compare_equal(CGPoint const actualValue, const U & expectedValue) {
        return CGPointEqualToPoint(actualValue, expectedValue);
    }

    template<typename U>
    bool compare_equal(CGAffineTransform const actualValue, const U & expectedValue) {
        return CGAffineTransformEqualToTransform(actualValue, expectedValue);
    }
}}}

#endif // __cplusplus
