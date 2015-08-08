#import <Foundation/Foundation.h>
#import "Base.h"

#pragma mark - private interface
namespace Cedar { namespace Matchers { namespace Private {
    template<typename T>
    class BeLTE : public Base<> {
    private:
        BeLTE<T> & operator=(const BeLTE<T> &);

    public:
        explicit BeLTE(const T & expectedValue);
        ~BeLTE();
        // Allow default copy ctor.

        template<typename U>
        bool matches(const U &) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        const T & expectedValue_;
        void validate_not_nil() const;
    };

    template<typename T>
    BeLTE<T>::BeLTE(const T & expectedValue) : Base<>(), expectedValue_(expectedValue) {
    }

    template<typename T>
    BeLTE<T>::~BeLTE() {
    }

    template<typename T>
    /*virtual*/ NSString * BeLTE<T>::failure_message_end() const {
        NSString * expectedValueString = Stringifiers::string_for(expectedValue_);
        return [NSString stringWithFormat:@"be less than or equal to <%@>", expectedValueString];
    }

    template<typename T> template<typename U>
    bool BeLTE<T>::matches(const U & actualValue) const {
        this->validate_not_nil();
        return !Comparators::compare_greater_than(actualValue, expectedValue_);
    }

    template<typename T>
    void BeLTE<T>::validate_not_nil() const {
        if (0 == strncmp(@encode(T), "@", 1) && [[NSValue value:&expectedValue_ withObjCType:@encode(T)] nonretainedObjectValue] == nil) {
            [[CDRSpecFailure specFailureWithReason:@"Unexpected use of be_less_than_or_equal_to matcher to check for nil; use the be_nil matcher to match nil values"] raise];
        }
    }


}}}

#pragma mark - public interface
namespace Cedar { namespace Matchers {
    template<typename T>
    using CedarBeLTE = Cedar::Matchers::Private::BeLTE<T>;

    template<typename T>
    CedarBeLTE<T> be_lte(const T & expectedValue) {
        return CedarBeLTE<T>(expectedValue);
    }

    template<typename T>
    CedarBeLTE<T> be_less_than_or_equal_to(const T & expectedValue) {
        return be_lte(expectedValue);
    }

#pragma mark operators
    template<typename T, typename U>
    bool operator<=(const ActualValue<T> & actualValue, const U & expectedValue) {
        return actualValue.to <= expectedValue;
    }

    template<typename T, typename U>
    bool operator<=(const ActualValueMatchProxy<T> & actualValueMatchProxy, const U & expectedValue) {
        actualValueMatchProxy(be_lte(expectedValue));
        return true;
    }
}}
