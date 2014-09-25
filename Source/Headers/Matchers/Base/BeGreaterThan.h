#import <Foundation/Foundation.h>
#import "Base.h"

namespace Cedar { namespace Matchers { namespace Private  {

    template<typename T>
    class BeGreaterThan : public Base<> {
    private:
        BeGreaterThan<T> & operator=(const BeGreaterThan<T> &);

    public:
        explicit BeGreaterThan(const T & expectedValue);
        ~BeGreaterThan();
        // Allow default copy ctor.

        template<typename U>
        bool matches(const U &) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        const T & expectedValue_;
    };

    template<typename T>
    BeGreaterThan<T>::BeGreaterThan(const T & expectedValue)
    : Base<>(), expectedValue_(expectedValue) {
    }

    template<typename T>
    BeGreaterThan<T>::~BeGreaterThan() {
    }

    template<typename T>
    /*virtual*/ NSString * BeGreaterThan<T>::failure_message_end() const {
        NSString * expectedValueString = Stringifiers::string_for(expectedValue_);
        return [NSString stringWithFormat:@"be greater than <%@>", expectedValueString];
    }

    template<typename T> template<typename U>
    bool BeGreaterThan<T>::matches(const U & actualValue) const {
        return Comparators::compare_greater_than(actualValue, expectedValue_);
    }
}}}

#pragma mark - public interface
namespace Cedar { namespace Matchers {
    template<typename T>
    using CedarBeGreaterThan = Cedar::Matchers::Private::BeGreaterThan<T>;

    template<typename T>
    CedarBeGreaterThan<T> be_greater_than(const T & expectedValue) {
        return CedarBeGreaterThan<T>(expectedValue);
    }

#pragma mark operators
    template<typename T, typename U>
    bool operator>(const ActualValue<T> & actualValue, const U & expectedValue) {
        return actualValue.to > expectedValue;
    }

    template<typename T, typename U>
    bool operator>(const ActualValueMatchProxy<T> & actualValueMatchProxy, const U & expectedValue) {
        actualValueMatchProxy(be_greater_than(expectedValue));
        return true;
    }
}}
