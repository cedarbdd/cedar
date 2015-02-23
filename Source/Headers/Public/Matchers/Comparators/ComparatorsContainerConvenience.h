namespace Cedar { namespace Matchers { namespace Comparators {
    template<typename T, typename U>
    bool compare_contains(const T & container, const U & element, contains_options options) {
        return compare_contains(container, element, options, [](const U & lhs, const U & rhs) { return compare_equal(lhs, rhs); });
    }
}}}
