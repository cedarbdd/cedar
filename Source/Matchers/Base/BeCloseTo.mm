#import "BeCloseTo.h"

namespace Cedar { namespace Matchers {

#pragma mark NSDecimalNumber
    template<>
    bool BeCloseTo<NSNumber *>::matches(NSDecimalNumber * const & actualValue) const {
        return this->matches([actualValue decimalValue]);
    }

    template<>
    bool BeCloseTo<NSDecimalNumber *>::matches(NSDecimalNumber * const & actualValue) const {
        return this->matches([actualValue decimalValue]);
    }

    template<>
    bool BeCloseTo<NSDecimalNumber *>::matches(NSNumber * const & actualValue) const {
        return this->matches([actualValue decimalValue]);
    }

#pragma mark NSDecimal
    template<>
    bool BeCloseTo<NSDecimal>::matches(NSDecimal const & actualValue) const {
        NSDecimal decimalThreshold = [@(threshold_) decimalValue];
        NSDecimal maxExpectedValue;
        NSDecimal minExpectedValue;
        NSDecimalAdd(&maxExpectedValue, &expectedValue_, &decimalThreshold, NSRoundPlain);
        NSDecimalSubtract(&minExpectedValue, &expectedValue_, &decimalThreshold, NSRoundPlain);
        return NSDecimalCompare(&actualValue, &minExpectedValue) != NSOrderedAscending && NSDecimalCompare(&actualValue, &maxExpectedValue) != NSOrderedDescending;
    }

    template<>
    bool BeCloseTo<NSNumber *>::matches(NSDecimal const & actualValue) const {
        NSDecimal decimalThreshold = [@(threshold_) decimalValue];
        NSDecimal expectedDecimal = [expectedValue_ decimalValue];
        NSDecimal maxExpectedValue;
        NSDecimal minExpectedValue;
        NSDecimalAdd(&maxExpectedValue, &expectedDecimal, &decimalThreshold, NSRoundPlain);
        NSDecimalSubtract(&minExpectedValue, &expectedDecimal, &decimalThreshold, NSRoundPlain);
        return NSDecimalCompare(&actualValue, &minExpectedValue) != NSOrderedAscending && NSDecimalCompare(&actualValue, &maxExpectedValue) != NSOrderedDescending;
    }

    template<>
    bool BeCloseTo<NSDecimalNumber *>::matches(NSDecimal const & actualValue) const {
        NSDecimal decimalThreshold = [@(threshold_) decimalValue];
        NSDecimal expectedDecimal = [expectedValue_ decimalValue];
        NSDecimal maxExpectedValue;
        NSDecimal minExpectedValue;
        NSDecimalAdd(&maxExpectedValue, &expectedDecimal, &decimalThreshold, NSRoundPlain);
        NSDecimalSubtract(&minExpectedValue, &expectedDecimal, &decimalThreshold, NSRoundPlain);
        return NSDecimalCompare(&actualValue, &minExpectedValue) != NSOrderedAscending && NSDecimalCompare(&actualValue, &maxExpectedValue) != NSOrderedDescending;
    }

    template<>
    bool BeCloseTo<NSDecimal>::matches(NSDecimalNumber * const & actualValue) const {
        return this->matches([actualValue decimalValue]);
    }

    template<>
    bool BeCloseTo<NSDecimal>::matches(NSNumber * const & actualValue) const {
        return this->matches([actualValue decimalValue]);
    }
}}
