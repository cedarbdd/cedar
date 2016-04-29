#import <Foundation/Foundation.h>
#import "Base.h"
#import "ComparatorsBase.h"

#ifdef __cplusplus

#pragma mark - Private interface
namespace Cedar { namespace Matchers { namespace Private {
    template<typename T>
    class Equal : public Base<> {
    private:
        Equal<T> & operator=(const Equal<T> &);

    public:
        explicit Equal(const T & expectedValue);
        ~Equal();
        // Allow default copy ctor.

        template<typename U>
        bool matches(const U &) const;

        template<typename U>
        NSString * failure_message_for(const U &) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        void validate_not_nil() const;

    private:
        const T & expectedValue_;
    };

    template<typename T>
    Equal<T>::Equal(const T & expectedValue) : Base<>(), expectedValue_(expectedValue) {
    }

    template<typename T>
    Equal<T>::~Equal() {
    }

    template<typename T> template<typename U>
    NSString * Equal<T>::failure_message_for(const U & value) const {
        if (0 == strncmp(@encode(T), "@", 1) &&
            0 == strncmp(@encode(U), "@", 1) &&
            [Stringifiers::string_for(expectedValue_) isEqualToString:Stringifiers::string_for(value)]) {
            Stringifiers::attempt_future_explication(&expectedValue_);
            Stringifiers::attempt_future_explication(&value);
        }
        return Base<>::failure_message_for(value);
    }

    template<typename T>
    /*virtual*/ NSString * Equal<T>::failure_message_end() const {
        NSString * expectedValueString = Stringifiers::string_for(expectedValue_);
        return [NSString stringWithFormat:@"equal <%@>", expectedValueString];
    }

    template<typename T> template<typename U>
    bool Equal<T>::matches(const U & actualValue) const {
        this->validate_not_nil();
        return Comparators::compare_equal(actualValue, expectedValue_);
    }

    template<typename T>
    void Equal<T>::validate_not_nil() const {
        if (0 == strncmp(@encode(T), "@", 1) && [[NSValue value:&expectedValue_ withObjCType:@encode(T)] nonretainedObjectValue] == nil) {
            [[CDRSpecFailure specFailureWithReason:@"Unexpected use of equal matcher to check for nil; use the be_nil matcher to match nil values"] raise];
        }
    }
}}}

#pragma mark - Public interface
namespace Cedar { namespace Matchers {
    template<typename T>
    using CedarEqual = Cedar::Matchers::Private::Equal<T>;

    template<typename T>
    CedarEqual<T> equal(const T &expectedValue) {
        return CedarEqual<T>(expectedValue);
    }

#pragma mark equality operators
    template<typename T, typename U>
    bool operator==(const ActualValue<T> & actualValue, const U & expectedValue) {
        return actualValue.to == expectedValue;
    }

    template<typename T, typename U>
    bool operator==(const ActualValueMatchProxy<T> & actualValueMatchProxy, const U & expectedValue) {
        actualValueMatchProxy(equal(expectedValue));
        return true;
    }

    template<typename T, typename U>
    bool operator!=(const ActualValue<T> & actualValue, const U & expectedValue) {
        return actualValue.to != expectedValue;
    }

    template<typename T, typename U>
    bool operator!=(const ActualValueMatchProxy<T> & actualValueMatchProxy, const U & expectedValue) {
        actualValueMatchProxy.negate()(equal(expectedValue));
        return true;
    }
}}

#endif // __cplusplus
