#import "BeCloseTo.h"

namespace Cedar { namespace Matchers {

    template<>
    bool BeCloseTo<NSNumber *>::matches(NSDecimalNumber * const & actualValue) const {
        NSDecimalNumber *decimalThreshold = [NSDecimalNumber decimalNumberWithDecimal:[@(threshold_) decimalValue]];
        NSDecimalNumber *expectedDecimalNumber = [NSDecimalNumber decimalNumberWithDecimal:[expectedValue_ decimalValue]];
        NSDecimalNumber *maxExpectedValue = [expectedDecimalNumber decimalNumberByAdding:decimalThreshold];
        NSDecimalNumber *minExpectedValue = [expectedDecimalNumber decimalNumberBySubtracting:decimalThreshold];
        return [actualValue compare:minExpectedValue] != NSOrderedAscending && [actualValue compare:maxExpectedValue] != NSOrderedDescending;
    }

    template<>
    bool BeCloseTo<NSDecimalNumber *>::matches(NSDecimalNumber * const & actualValue) const {
        NSDecimalNumber *decimalThreshold = [NSDecimalNumber decimalNumberWithDecimal:[@(threshold_) decimalValue]];
        NSDecimalNumber *maxExpectedValue = [expectedValue_ decimalNumberByAdding:decimalThreshold];
        NSDecimalNumber *minExpectedValue = [expectedValue_ decimalNumberBySubtracting:decimalThreshold];
        return [actualValue compare:minExpectedValue] != NSOrderedAscending && [actualValue compare:maxExpectedValue] != NSOrderedDescending;
    }

    template<>
    bool BeCloseTo<NSDecimalNumber *>::matches(NSNumber * const & actualValue) const {
        NSDecimalNumber *decimalThreshold = [NSDecimalNumber decimalNumberWithDecimal:[@(threshold_) decimalValue]];
        NSDecimalNumber *actualDecimalNumber = [NSDecimalNumber decimalNumberWithDecimal:[actualValue decimalValue]];

        NSDecimalNumber *maxExpectedValue = [expectedValue_ decimalNumberByAdding:decimalThreshold];
        NSDecimalNumber *minExpectedValue = [expectedValue_ decimalNumberBySubtracting:decimalThreshold];
        return [actualDecimalNumber compare:minExpectedValue] != NSOrderedAscending && [actualDecimalNumber compare:maxExpectedValue] != NSOrderedDescending;
    }
}}
