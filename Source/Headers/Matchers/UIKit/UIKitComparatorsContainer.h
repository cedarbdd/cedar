#import <UIKit/UIView.h>
#import <QuartzCore/QuartzCore.h>

namespace Cedar { namespace Matchers { namespace Comparators {
    template<typename U>
    bool compare_contains(UIView * const container, const U & element, bool nested) {
        return compare_contains(container, element, @"subviews", nested);
    }

    template<typename U>
    bool compare_contains(CALayer * const container, const U & element, bool nested) {
        return compare_contains(container, element, @"sublayers", nested);
    }
}}}
