#import "CDRSpecFailure.h"

namespace Cedar { namespace Matchers { namespace Comparators {
    inline bool compare_close_to(const double actualValue, const double expectedValue, const double threshold) {
        return actualValue > expectedValue - threshold && actualValue < expectedValue + threshold;
    }

    inline bool compare_close_to(const NSDecimal & actualValue, const NSDecimal & expectedValue, const double threshold) {
        NSDecimal decimalThreshold = [@(threshold) decimalValue];
        NSDecimal maxExpectedValue;
        NSDecimal minExpectedValue;
        NSDecimalAdd(&maxExpectedValue, &expectedValue, &decimalThreshold, NSRoundPlain);
        NSDecimalSubtract(&minExpectedValue, &expectedValue, &decimalThreshold, NSRoundPlain);
        return NSDecimalCompare(&actualValue, &minExpectedValue) != NSOrderedAscending && NSDecimalCompare(&actualValue, &maxExpectedValue) != NSOrderedDescending;
    }

    inline bool compare_close_to(const id actualValue, const id expectedValue, const double threshold) {
        if ([expectedValue isKindOfClass:[NSNumber class]] && [actualValue isKindOfClass:[NSNumber class]]) {
            return compare_close_to([actualValue decimalValue], [expectedValue decimalValue], threshold);
        }
        if ([expectedValue isKindOfClass:[NSDate class]] && [actualValue isKindOfClass:[NSDate class]]) {
            return compare_close_to([actualValue timeIntervalSince1970], [expectedValue timeIntervalSince1970], threshold);
        }

        NSString *reason = [NSString stringWithFormat:@"Actual value <%@> (%@) is not a numeric value (NSNumber, NSDate, float, etc.)",
                            actualValue, NSStringFromClass([actualValue class])];
        [[CDRSpecFailure specFailureWithReason:reason] raise];
        return false;
    }
}}}
