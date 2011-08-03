#import <Foundation/Foundation.h>
#import "Base.h"

namespace Cedar { namespace Matchers {
    template<typename T>
    class Equal : public Base {
    private:
        Equal<T> & operator=(const Equal<T> &);

    public:
        explicit Equal(const T & expectedValue);
        ~Equal();
        // Allow default copy ctor.

        template<typename U>
        bool matches(const U &) const;
        bool matches(const id &) const;
        bool matches(NSObject * const &) const;
        bool matches(NSString * const &) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        const T & expectedValue_;
    };

    template<typename T>
    Equal<T> equal(const T & expectedValue) {
        return Equal<T>(expectedValue);
    }

    template<typename T>
    Equal<T>::Equal(const T & expectedValue)
    : Base(), expectedValue_(expectedValue) {
    }

    template<typename T>
    Equal<T>::~Equal() {
    }

    template<typename T>
    /*virtual*/ NSString * Equal<T>::failure_message_end() const {
        return [NSString stringWithFormat:@"equal <%@>", this->string_for(expectedValue_)];
    }

#pragma mark Generic
    template<typename T> template<typename U>
    bool Equal<T>::matches(const U & actualValue) const {
        this->build_failure_message_start(actualValue);
        return expectedValue_ == actualValue;
    }

#pragma mark id
    template<typename T>
    bool Equal<T>::matches(const id & actualValue) const {
        this->build_failure_message_start(actualValue);
        return [actualValue isEqual:expectedValue_];
    }

    template<> template<typename U>
    bool Equal<id>::matches(const U & actualValue) const {
        [[CDRSpecFailure specFailureWithReason:@"Attempt to compare id to incomparable type"] raise];
    }

#pragma mark NSObject
    template<typename T>
    bool Equal<T>::matches(NSObject * const & actualValue) const {
        return this->matches(static_cast<const id &>(actualValue));
    }

    template<> template<typename U>
    bool Equal<NSObject *>::matches(const U & actualValue) const {
        [[CDRSpecFailure specFailureWithReason:@"Attempt to compare NSObject * to incomparable type"] raise];
    }

#pragma mark NSString
    template<typename T>
    bool Equal<T>::matches(NSString * const & actualValue) const {
        return this->matches(static_cast<const id &>(actualValue));
    }

    template<> template<typename U>
    bool Equal<NSString *>::matches(const U & actualValue) const {
        [[CDRSpecFailure specFailureWithReason:@"Attempt to compare NSString * to incomparable type"] raise];
    }
}}
