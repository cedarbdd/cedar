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

#pragma mark NSDecimal
    inline bool compare_equal(const NSDecimal & actualValue, const NSDecimal & expectedValue) {
        return NSOrderedSame == NSDecimalCompare(&actualValue, &expectedValue);
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

#pragma mark NSRange
    template<typename U>
    bool compare_equal(const NSRange actualValue, const U & expectedValue) {
        return NSEqualRanges(actualValue, expectedValue);
    }
}}}
