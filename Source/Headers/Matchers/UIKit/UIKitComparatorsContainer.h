#import <UIKit/UIView.h>
#import <QuartzCore/QuartzCore.h>

namespace Cedar { namespace Matchers { namespace Comparators {
    template<typename U, typename F>
    bool compare_contains(UIView * const container, const U & element, contains_options options, F comparator) {
        return compare_contains(container, element, @"subviews", options, comparator);
    }

    template<typename U, typename F>
    bool compare_contains(CALayer * const container, const U & element, contains_options options, F comparator) {
        return compare_contains(container, element, @"sublayers", options, comparator);
    }
}}}
