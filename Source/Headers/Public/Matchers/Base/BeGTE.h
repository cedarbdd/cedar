#import <Foundation/Foundation.h>
#import "Base.h"

#pragma mark - private interface
namespace Cedar { namespace Matchers { namespace Private {
    template<typename T>
    class BeGTE : public Base<> {
    private:
        BeGTE<T> & operator=(const BeGTE<T> &);

    public:
        explicit BeGTE(const T & expectedValue);
        ~BeGTE();
        // Allow default copy ctor.

        template<typename U>
        bool matches(const U &) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        void validate_not_nil() const;
        const T & expectedValue_;

    };


    template<typename T>
    BeGTE<T>::BeGTE(const T & expectedValue) : Base<>(), expectedValue_(expectedValue) {
    }

    template<typename T>
    BeGTE<T>::~BeGTE() {
    }

    template<typename T>
    /*virtual*/ NSString * BeGTE<T>::failure_message_end() const {
        NSString * expectedValueString = Stringifiers::string_for(expectedValue_);
        return [NSString stringWithFormat:@"be greater than or equal to <%@>", expectedValueString];
    }

    template<typename T> template<typename U>
    bool BeGTE<T>::matches(const U & actualValue) const {
        this->validate_not_nil();
        return Comparators::compare_greater_than(actualValue, expectedValue_) || Comparators::compare_equal(actualValue, expectedValue_);
    }

    template<typename T>
    void BeGTE<T>::validate_not_nil() const {
        if (0 == strncmp(@encode(T), "@", 1) && [[NSValue value:&expectedValue_ withObjCType:@encode(T)] nonretainedObjectValue] == nil) {
            [[CDRSpecFailure specFailureWithReason:@"Unexpected use of be_greater_than_or_equal_to matcher to check for nil; use the be_nil matcher to match nil values"] raise];
        }
    }
}}}

#pragma mark - public interface
namespace Cedar { namespace Matchers {
    template<typename T>
    using CedarBeGTE  = Cedar::Matchers::Private::BeGTE<T>;

    template<typename T>
    CedarBeGTE<T> be_gte(const T & expectedValue) {
        return CedarBeGTE<T>(expectedValue);
    }

    template<typename T>
    CedarBeGTE<T> be_greater_than_or_equal_to(const T & expectedValue) {
        return be_gte(expectedValue);
    }

#pragma mark operators
    template<typename T, typename U>
    bool operator>=(const ActualValue<T> & actualValue, const U & expectedValue) {
        return actualValue.to >= expectedValue;
    }

    template<typename T, typename U>
    bool operator>=(const ActualValueMatchProxy<T> & actualValueMatchProxy, const U & expectedValue) {
        actualValueMatchProxy(be_gte(expectedValue));
        return true;
    }
}}
