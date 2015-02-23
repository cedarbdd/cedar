namespace Cedar { namespace Matchers { namespace Comparators {

#pragma mark Generic
    template<typename T, typename U>
    bool compare_greater_than(const T & actualValue, const U & expectedValue) {
        if (strcmp(@encode(T), "@") == 0 && strcmp(@encode(U), "@") == 0) {
            NSValue *actualValueId = [NSValue value:&actualValue withObjCType:@encode(id)];
            NSValue *expectedValueId = [NSValue value:&expectedValue withObjCType:@encode(id)];
            id actualValueObject = [actualValueId nonretainedObjectValue];
            id expectedValueObject = [expectedValueId nonretainedObjectValue];
            if ([actualValueObject respondsToSelector:@selector(compare:)]) {
                return NSOrderedDescending == [actualValueObject compare:expectedValueObject];
            } else if ([expectedValueObject respondsToSelector:@selector(compare:)]) {
                return NSOrderedAscending == [expectedValueObject compare:actualValueObject];
            }
            return false;
        } else {
            return actualValue > expectedValue;
        }
    }

#pragma mark NSDecimal
    inline bool compare_greater_than(const NSDecimal & actualValue, const NSDecimal & expectedValue) {
        return NSOrderedDescending == NSDecimalCompare(&actualValue, &expectedValue);
    }
}}}
