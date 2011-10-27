namespace Cedar { namespace Matchers { namespace Comparators {

#pragma mark Generic
    template<typename T, typename U>
    bool compare_equal(const T & actualValue, const U & expectedValue) {
        return actualValue == expectedValue;
    }

#pragma mark id
    template<typename U>
    bool compare_equal(const id & actualValue, const U & expectedValue) {
        return [actualValue isEqual:expectedValue];
    }

#pragma mark NSObject
    template<typename U>
    bool compare_equal(NSObject * const actualValue, const U & expectedValue) {
        return [actualValue isEqual:expectedValue];
    }

#pragma mark NSString
    template<typename U>
    bool compare_equal(NSString * const actualValue, const U & expectedValue) {
        return compare_equal(static_cast<const id &>(actualValue), expectedValue);
    }

#pragma mark NSMutableString
    template<typename U>
    bool compare_equal(NSMutableString * const actualValue, const U & expectedValue) {
        return compare_equal(static_cast<NSString * const>(actualValue), expectedValue);
    }

#pragma mark NSNumber
    inline bool compare_equal(NSNumber * const actualValue, NSNumber * const expectedValue) {
        return [actualValue isEqualToNumber:expectedValue];
    }

    inline bool compare_equal(NSNumber * const actualValue, const id expectedValue) {
        return [expectedValue isEqual:actualValue];
    }

    inline bool compare_equal(NSNumber * const actualValue, NSObject * const expectedValue) {
        return compare_equal(actualValue, static_cast<const id>(expectedValue));
    }

    inline bool compare_equal(NSNumber * const actualValue, NSValue * const expectedValue) {
        return compare_equal(actualValue, static_cast<const id>(expectedValue));
    }

    inline bool compare_equal(const id actualValue, NSNumber * const expectedValue) {
        return compare_equal(expectedValue, actualValue);
    }

    inline bool compare_equal(NSObject * const actualValue, NSNumber * const expectedValue) {
        return compare_equal(expectedValue, actualValue);
    }

    template<typename U>
    bool compare_equal(NSNumber * const actualValue, const U & expectedValue) {
        return [actualValue floatValue] == expectedValue;
    }

    template<typename T>
    bool compare_equal(const T & actualValue, NSNumber * const expectedValue) {
        return compare_equal(expectedValue, actualValue);
    }

}}}
