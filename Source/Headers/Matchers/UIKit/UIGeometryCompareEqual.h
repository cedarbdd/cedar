#import <UIKit/UIGeometry.h>
#import <UIKit/UIKit.h>

#import "ComparatorsBase.h"
#import "UIGeometryStringifiers.h"

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
    bool compare_equal(UIEdgeInsets const actualValue, const U & expectedValue) {
        return UIEdgeInsetsEqualToEdgeInsets(actualValue, expectedValue);
    }

    template<typename U>
    bool compare_equal(CGAffineTransform const actualValue, const U & expectedValue) {
        return CGAffineTransformEqualToTransform(actualValue, expectedValue);
    }

    template<typename U>
    bool compare_equal(UIImage *actualImage, const U & expectedImage) {
        return [expectedImage isEqual:actualImage] || [UIImagePNGRepresentation(expectedImage) isEqual:UIImagePNGRepresentation(actualImage)];
    }
}}}
