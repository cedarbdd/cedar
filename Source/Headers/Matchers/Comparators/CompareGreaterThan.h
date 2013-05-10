namespace Cedar { namespace Matchers { namespace Comparators {

#pragma mark Generic
    template<typename T, typename U>
    bool compare_greater_than(const T & actualValue, const U & expectedValue) {
        return actualValue > expectedValue;
    }

#pragma mark NSNumber
    template<typename T>
    bool compare_greater_than(const T & actualValue, NSNumber * const expectedValue) {
        return actualValue > [expectedValue floatValue];
    }

    template<typename U>
    bool compare_greater_than(NSNumber * const actualValue, const U & expectedValue) {
        return [actualValue floatValue] > expectedValue;
    }

    inline bool compare_greater_than(NSNumber * const actualValue, NSNumber * const expectedValue) {
        return NSOrderedDescending == [actualValue compare:expectedValue];
    }

    inline bool compare_greater_than(NSNumber * const actualValue, const id expectedValue) {
        if ([expectedValue respondsToSelector:@selector(floatValue)]) {
            return compare_greater_than(actualValue, [expectedValue floatValue]);
        }
        return false;
    }

    inline bool compare_greater_than(NSNumber * const actualValue, NSObject * const expectedValue) {
        return compare_greater_than(actualValue, static_cast<const id>(expectedValue));
    }

    inline bool compare_greater_than(NSNumber * const actualValue, NSValue * const expectedValue) {
        return compare_greater_than(actualValue, static_cast<const id>(expectedValue));
    }

    inline bool compare_greater_than(const id actualValue, NSNumber * const expectedValue) {
        if ([actualValue respondsToSelector:@selector(floatValue)]) {
            return compare_greater_than([actualValue floatValue], expectedValue);
        }
        return false;
    }

    inline bool compare_greater_than(NSObject * const actualValue, NSNumber * const expectedValue) {
        return compare_greater_than(static_cast<const id>(actualValue), expectedValue);
    }

    inline bool compare_greater_than(NSValue * const actualValue, NSNumber * const expectedValue) {
        return compare_greater_than(static_cast<const id>(actualValue), expectedValue);
    }

#pragma mark NSDecimalNumber
    template<typename T>
    bool compare_greater_than(const T actualValue, NSDecimalNumber * const expectedValue) {
        return NSOrderedDescending == [@(actualValue) compare:expectedValue];
    }

    template<typename U>
    bool compare_greater_than(NSDecimalNumber * const actualValue, const U & expectedValue) {
        return NSOrderedDescending == [actualValue compare:@(expectedValue)];
    }

    inline bool compare_greater_than(NSDecimalNumber * const actualValue, NSDecimalNumber * const expectedValue) {
        return NSOrderedDescending == [actualValue compare:expectedValue];
    }

    inline bool compare_greater_than(NSDecimalNumber * const actualValue, NSNumber * const expectedValue) {
        return compare_greater_than(actualValue, [NSDecimalNumber decimalNumberWithDecimal:[expectedValue decimalValue]]);
    }

    inline bool compare_greater_than(NSDecimalNumber * const actualValue, const id expectedValue) {
        if ([expectedValue respondsToSelector:@selector(decimalValue)]) {
            return compare_greater_than(actualValue, [NSDecimalNumber decimalNumberWithDecimal:[expectedValue decimalValue]]);
        }
        return false;
    }

    inline bool compare_greater_than(NSDecimalNumber * const actualValue, NSObject * const expectedValue) {
        return compare_greater_than(actualValue, static_cast<const id>(expectedValue));
    }

    inline bool compare_greater_than(NSDecimalNumber * const actualValue, NSValue * const expectedValue) {
        return compare_greater_than(actualValue, static_cast<const id>(expectedValue));
    }


    inline bool compare_greater_than(NSNumber * const actualValue, NSDecimalNumber * const expectedValue) {
        return compare_greater_than([NSDecimalNumber decimalNumberWithDecimal:[actualValue decimalValue]], expectedValue);
    }

    inline bool compare_greater_than(const id actualValue, NSDecimalNumber * const expectedValue) {
        if ([actualValue respondsToSelector:@selector(decimalValue)]) {
            return compare_greater_than([NSDecimalNumber decimalNumberWithDecimal:[actualValue decimalValue]], expectedValue);
        }
        return false;
    }

    inline bool compare_greater_than(NSValue * const actualValue, NSDecimalNumber * const expectedValue) {
        return compare_greater_than(static_cast<const id>(actualValue), expectedValue);
    }

    inline bool compare_greater_than(NSObject * const actualValue, NSDecimalNumber * const expectedValue) {
        return compare_greater_than(static_cast<const id>(actualValue), expectedValue);
    }

#pragma mark NSDecimal
    inline bool compare_greater_than(const NSDecimal & actualValue, const NSDecimal & expectedValue) {
        return NSOrderedDescending == NSDecimalCompare(&actualValue, &expectedValue);
    }

    inline bool compare_greater_than(const NSDecimal & actualValue, NSDecimalNumber * const expectedValue) {
        return compare_greater_than(actualValue, [expectedValue decimalValue]);
    }

    inline bool compare_greater_than(const NSDecimal & actualValue, const id expectedValue) {
        if ([expectedValue respondsToSelector:@selector(decimalValue)]) {
            return compare_greater_than(actualValue, [expectedValue decimalValue]);
        }
        return false;
    }

    inline bool compare_greater_than(const NSDecimal & actualValue, NSValue * const expectedValue) {
        return compare_greater_than(actualValue, static_cast<const id>(expectedValue));
    }

    inline bool compare_greater_than(const NSDecimal & actualValue, NSNumber * const expectedValue) {
        return compare_greater_than(actualValue, static_cast<const id>(expectedValue));
    }

    inline bool compare_greater_than(const NSDecimal & actualValue, NSObject * const expectedValue) {
        return compare_greater_than(actualValue, static_cast<const id>(expectedValue));
    }

    inline bool compare_greater_than(NSDecimalNumber * const actualValue, const NSDecimal & expectedValue) {
        return compare_greater_than([actualValue decimalValue], expectedValue);
    }

    inline bool compare_greater_than(const id actualValue, const NSDecimal & expectedValue) {
        if ([actualValue respondsToSelector:@selector(decimalValue)]) {
            return compare_greater_than([actualValue decimalValue], expectedValue);
        }
        return false;
    }

    inline bool compare_greater_than(NSNumber * const actualValue, const NSDecimal & expectedValue) {
        return compare_greater_than(static_cast<const id>(actualValue), expectedValue);
    }

    inline bool compare_greater_than(NSValue * const actualValue, const NSDecimal & expectedValue) {
        return compare_greater_than(static_cast<const id>(actualValue), expectedValue);
    }

    inline bool compare_greater_than(NSObject * const actualValue, const NSDecimal & expectedValue) {
        return compare_greater_than(static_cast<const id>(actualValue), expectedValue);
    }

    template<typename U>
    inline bool compare_greater_than(const NSDecimal & actualValue, const U & expectedValue) {
        return compare_greater_than(actualValue, @(expectedValue));
    }

    template<typename T>
    inline bool compare_greater_than(const T & actualValue, const NSDecimal & expectedValue) {
        return compare_greater_than(@(actualValue), expectedValue);
    }
}}}
