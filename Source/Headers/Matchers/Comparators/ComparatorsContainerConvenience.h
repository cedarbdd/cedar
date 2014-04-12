#import "ComparatorsContainer.h"

namespace Cedar { namespace Matchers { namespace Comparators {
    template<typename T, typename U>
    bool compare_contains(const T & container, const U & element, bool nested) {
        return compare_contains(container, element, nested, [](const U & lhs, const U & rhs) { return compare_equal(lhs, rhs); });
    }
}}}
