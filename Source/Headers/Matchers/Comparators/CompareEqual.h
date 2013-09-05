namespace Cedar { namespace Matchers { namespace Comparators {

#pragma mark Generic
    template<typename T, typename U>
    bool compare_equal(const T & actualValue, const U & expectedValue) {
        if (strcmp(@encode(T), "@") == 0 && strcmp(@encode(U), "@") == 0) {
            NSValue *actualValueId = [NSValue value:&actualValue withObjCType:@encode(id)];
            NSValue *expectedValueId = [NSValue value:&expectedValue withObjCType:@encode(id)];
            return [[actualValueId nonretainedObjectValue] isEqual:[expectedValueId nonretainedObjectValue]];
        } else {
            return actualValue == expectedValue;
        }
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

#pragma mark NSDecimalNumber
    inline bool compare_equal(NSDecimalNumber * const actualValue, NSDecimalNumber * const expectedValue) {
        return compare_equal(actualValue, static_cast<const id>(expectedValue));
    }

    inline bool compare_equal(NSDecimalNumber * const actualValue, NSNumber * const expectedValue) {
        return compare_equal(actualValue, static_cast<const id>(expectedValue));
    }

    inline bool compare_equal(NSNumber * const actualValue, NSDecimalNumber * const expectedValue) {
        return compare_equal(expectedValue, static_cast<const id>(actualValue));
    }

    inline bool compare_equal(NSDecimalNumber * const actualValue, const id expectedValue) {
        return [expectedValue isEqual:actualValue];
    }

    inline bool compare_equal(NSDecimalNumber * const actualValue, NSObject * const expectedValue) {
        return compare_equal(actualValue, static_cast<const id>(expectedValue));
    }

    inline bool compare_equal(NSDecimalNumber * const actualValue, NSValue * const expectedValue) {
        return compare_equal(actualValue, static_cast<const id>(expectedValue));
    }

    template<typename U>
    bool compare_equal(NSDecimalNumber * const actualValue, const U & expectedValue) {
        return compare_equal(actualValue, @(expectedValue));
    }

    template<typename T>
    bool compare_equal(const T & actualValue, NSDecimalNumber * const expectedValue) {
        return compare_equal(expectedValue, actualValue);
    }

#pragma mark NSDecimal
    inline bool compare_equal(const NSDecimal & actualValue, const id expectedValue) {
        return [[NSDecimalNumber decimalNumberWithDecimal:actualValue] isEqual:expectedValue];
    }

    inline bool compare_equal(const id actualValue, const NSDecimal & expectedValue) {
        return compare_equal(expectedValue, actualValue);
    }

    inline bool compare_equal(const NSDecimal & actualValue, NSNumber * const expectedValue) {
        return compare_equal(actualValue, static_cast<const id>(expectedValue));
    }

    inline bool compare_equal(NSNumber * const actualValue, const NSDecimal & expectedValue) {
        return compare_equal(expectedValue, static_cast<const id>(actualValue));
    }

    inline bool compare_equal(const NSDecimal & actualValue, NSObject * const expectedValue) {
        return compare_equal(actualValue, static_cast<const id>(expectedValue));
    }

    inline bool compare_equal(NSObject * const actualValue, const NSDecimal & expectedValue) {
        return compare_equal(expectedValue, static_cast<const id>(actualValue));
    }

    inline bool compare_equal(const NSDecimal & actualValue, NSValue * const expectedValue) {
        return compare_equal(actualValue, static_cast<const id>(expectedValue));
    }

    inline bool compare_equal(NSValue * const actualValue, const NSDecimal & expectedValue) {
        return compare_equal(expectedValue, static_cast<const id>(actualValue));
    }

    inline bool compare_equal(const NSDecimal & actualValue, const NSDecimal & expectedValue) {
        return NSOrderedSame == NSDecimalCompare(&actualValue, &expectedValue);
    }

    inline bool compare_equal(const NSDecimal & actualValue, NSDecimalNumber * const expectedValue) {
        return compare_equal(actualValue, [expectedValue decimalValue]);
    }

    inline bool compare_equal(NSDecimalNumber * const actualValue, const NSDecimal & expectedValue) {
        return compare_equal([actualValue decimalValue], expectedValue);
    }

    template<typename U>
    bool compare_equal(const NSDecimal & actualValue, const U & expectedValue) {
        return compare_equal(actualValue, @(expectedValue));
    }

    template<typename T>
    bool compare_equal(const T & actualValue, const NSDecimal & expectedValue) {
        return compare_equal(@(actualValue), expectedValue);
    }

#pragma mark C Strings
    template<typename U>
    bool compare_equal(char *actualValue, const U & expectedValue) {
        return strcmp(actualValue, expectedValue) == 0;
    }

    template<typename U>
    bool compare_equal(const char *actualValue, const U & expectedValue) {
        return strcmp(actualValue, expectedValue) == 0;
    }
}}}
