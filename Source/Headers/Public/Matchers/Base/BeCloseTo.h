#import <Foundation/Foundation.h>
#import "Base.h"
#import "CedarComparators.h"
#import "CDRSpecFailure.h"

#pragma mark private interface
namespace Cedar { namespace Matchers { namespace Private {
    template<typename T>
    class BeCloseTo : public Base<> {
    private:
        BeCloseTo<T> & operator=(const BeCloseTo<T> &);

    public:
        explicit BeCloseTo(const T & expectedValue);
        ~BeCloseTo();
        // Allow default copy ctor.

        BeCloseTo<T> &within(double threshold);

        template<typename U>
        bool matches(const U &) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        void validate_not_nil() const;

    private:
        const T & expectedValue_;
        double threshold_;
    };

    template<typename T>
    BeCloseTo<T>::BeCloseTo(const T & expectedValue) : Base<>(), expectedValue_(expectedValue), threshold_(0.01) {
    }

    template<typename T>
    BeCloseTo<T>::~BeCloseTo() {
    }

    template<typename T>
    BeCloseTo<T> & BeCloseTo<T>::within(double threshold) {
        threshold_ = threshold;
        return *this;
    }

    template<typename T>
    /*virtual*/ NSString * BeCloseTo<T>::failure_message_end() const {
        NSString * expectedValueString = Stringifiers::string_for(expectedValue_);
        NSString * thresholdString = Stringifiers::string_for(threshold_);
        return [NSString stringWithFormat:@"be close to <%@> (within %@)", expectedValueString, thresholdString];
    }

    template<typename T> template<typename U>
    bool BeCloseTo<T>::matches(const U & actualValue) const {
        this->validate_not_nil();
        return Comparators::compare_close_to(actualValue, expectedValue_, threshold_);
    }

    template<typename T>
    void BeCloseTo<T>::validate_not_nil() const {
        if (0 == strncmp(@encode(T), "@", 1) && [[NSValue value:&expectedValue_ withObjCType:@encode(T)] nonretainedObjectValue] == nil) {
            [[CDRSpecFailure specFailureWithReason:@"Unexpected use of be_close_to matcher to check for nil; use the be_nil matcher to match nil values"] raise];
        }
    }
}}}

#pragma mark public interface
namespace Cedar { namespace Matchers {
    template<typename T>
    using CedarBeCloseTo = Cedar::Matchers::Private::BeCloseTo<T>;

    template<typename T>
    CedarBeCloseTo<T> be_close_to(const T & expectedValue) {
        return CedarBeCloseTo<T>(expectedValue);
    }
}}
