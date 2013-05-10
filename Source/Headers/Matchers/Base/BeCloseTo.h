#import <Foundation/Foundation.h>
#import "Base.h"

namespace Cedar { namespace Matchers {
    template<typename T>
    class BeCloseTo : public Base<> {
    private:
        BeCloseTo<T> & operator=(const BeCloseTo<T> &);

    public:
        explicit BeCloseTo(const T & expectedValue);
        ~BeCloseTo();
        // Allow default copy ctor.

        BeCloseTo<T> & within(float threshold);

        template<typename U>
        bool matches(const U &) const;
        bool matches(NSNumber * const &) const;
        bool matches(NSDecimalNumber * const &) const;
        bool matches(NSDecimal const &) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        template<typename U, typename V>
        bool subtractable_types_match(const U &, const V &) const;

    private:
        const T & expectedValue_;
        float threshold_;
    };

    template<typename T>
    BeCloseTo<T> be_close_to(const T & expectedValue) {
        return BeCloseTo<T>(expectedValue);
    }

    template<typename T>
    BeCloseTo<T>::BeCloseTo(const T & expectedValue)
    : Base<>(), expectedValue_(expectedValue), threshold_(0.01) {
    }

    template<typename T>
    BeCloseTo<T>::~BeCloseTo() {
    }

    template<typename T>
    BeCloseTo<T> & BeCloseTo<T>::within(float threshold) {
        threshold_ = threshold;
        return *this;
    }

    template<typename T>
    /*virtual*/ NSString * BeCloseTo<T>::failure_message_end() const {
        NSString * expectedValueString = Stringifiers::string_for(expectedValue_);
        NSString * thresholdString = Stringifiers::string_for(threshold_);
        return [NSString stringWithFormat:@"be close to <%@> (within %@)", expectedValueString, thresholdString];
    }

    template<typename T> template<typename U, typename V>
    bool BeCloseTo<T>::subtractable_types_match(const U & actualValue, const V & expectedValue) const {
        return actualValue > expectedValue - threshold_ && actualValue < expectedValue + threshold_;
    }

#pragma mark Generic
    template<typename T> template<typename U>
    bool BeCloseTo<T>::matches(const U & actualValue) const {
        return this->subtractable_types_match(actualValue, expectedValue_);
    }

#pragma mark NSNumber
    template<typename T>
    bool BeCloseTo<T>::matches(NSNumber * const & actualValue) const {
        return this->matches([actualValue floatValue]);
    }

    template<> template<typename U>
    bool BeCloseTo<NSNumber *>::matches(const U & actualValue) const {
        return this->subtractable_types_match(actualValue, [expectedValue_ floatValue]);
    }

#pragma mark NSDecimalNumber
    template<typename T>
    bool BeCloseTo<T>::matches(NSDecimalNumber * const & actualValue) const {
        NSDecimalNumber *decimalThreshold = [NSDecimalNumber decimalNumberWithDecimal:[@(threshold_) decimalValue]];
        NSDecimalNumber *expectedDecimalNumber = [NSDecimalNumber decimalNumberWithDecimal:[@(expectedValue_) decimalValue]];
        NSDecimalNumber *maxExpectedValue = [expectedDecimalNumber decimalNumberByAdding:decimalThreshold];
        NSDecimalNumber *minExpectedValue = [expectedDecimalNumber decimalNumberBySubtracting:decimalThreshold];
        return [actualValue compare:minExpectedValue] != NSOrderedAscending && [actualValue compare:maxExpectedValue] != NSOrderedDescending;

    }

    template<> template<typename U>
    bool BeCloseTo<NSDecimalNumber *>::matches(const U & actualValue) const {
        NSDecimalNumber *decimalThreshold = [NSDecimalNumber decimalNumberWithDecimal:[@(threshold_) decimalValue]];
        NSDecimalNumber *actualDecimalNumber = [NSDecimalNumber decimalNumberWithDecimal:[@(actualValue) decimalValue]];
        NSDecimalNumber *maxExpectedValue = [expectedValue_ decimalNumberByAdding:decimalThreshold];
        NSDecimalNumber *minExpectedValue = [expectedValue_ decimalNumberBySubtracting:decimalThreshold];
        return [actualDecimalNumber compare:minExpectedValue] != NSOrderedAscending && [actualDecimalNumber compare:maxExpectedValue] != NSOrderedDescending;
    }

    template<>
    bool BeCloseTo<NSNumber *>::matches(NSDecimalNumber * const & actualValue) const;

    template<>
    bool BeCloseTo<NSDecimalNumber *>::matches(NSDecimalNumber * const & actualValue) const;

    template<>
    bool BeCloseTo<NSDecimalNumber *>::matches(NSNumber * const & actualValue) const;

#pragma mark NSDecimal
    template<typename T>
    bool BeCloseTo<T>::matches(NSDecimal const & actualValue) const {
        NSDecimal decimalThreshold = [@(threshold_) decimalValue];
        NSDecimal expectedDecimal = [@(expectedValue_) decimalValue];
        NSDecimal maxExpectedValue;
        NSDecimal minExpectedValue;
        NSDecimalAdd(&maxExpectedValue, &expectedDecimal, &decimalThreshold, NSRoundPlain);
        NSDecimalSubtract(&minExpectedValue, &expectedDecimal, &decimalThreshold, NSRoundPlain);
        return NSDecimalCompare(&actualValue, &minExpectedValue) != NSOrderedAscending && NSDecimalCompare(&actualValue, &maxExpectedValue) != NSOrderedDescending;
    }

    template<> template<typename U>
    bool BeCloseTo<NSDecimal>::matches(const U & actualValue) const {
        NSDecimal decimalThreshold = [@(threshold_) decimalValue];
        NSDecimal actualDecimal = [@(actualValue) decimalValue];
        NSDecimal maxExpectedValue;
        NSDecimal minExpectedValue;
        NSDecimalAdd(&maxExpectedValue, &expectedValue_, &decimalThreshold, NSRoundPlain);
        NSDecimalSubtract(&minExpectedValue, &expectedValue_, &decimalThreshold, NSRoundPlain);
        return NSDecimalCompare(&actualDecimal, &minExpectedValue) != NSOrderedAscending && NSDecimalCompare(&actualDecimal, &maxExpectedValue) != NSOrderedDescending;
    }

    template<>
    bool BeCloseTo<NSNumber *>::matches(NSDecimal const & actualValue) const;

    template<>
    bool BeCloseTo<NSDecimal>::matches(NSDecimal const & actualValue) const;

    template<>
    bool BeCloseTo<NSDecimalNumber *>::matches(NSDecimal const & actualValue) const;

    template<>
    bool BeCloseTo<NSDecimal>::matches(NSDecimalNumber * const & actualValue) const;

    template<>
    bool BeCloseTo<NSDecimal>::matches(NSNumber * const & actualValue) const;
}}
