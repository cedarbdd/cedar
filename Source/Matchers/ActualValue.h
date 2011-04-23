#import <Foundation/Foundation.h>
#import "CDRSpecFailure.h"

#include <iostream>
#include <sstream>

namespace Cedar { namespace Matchers {

    void fail(const NSString * failureMessage);

    template<typename T>
    class ActualValue {
    private:
        template<typename U>
        ActualValue(const ActualValue<U> &);
        template<typename U>
        ActualValue & operator=(const ActualValue<U> &);

    public:
        ActualValue(const T &);

        template<typename Matcher> void to(const Matcher &) const;
        template<typename Matcher> void to_not(const Matcher &) const;

    private:
        const T value_;
    };

    template<typename T>
    ActualValue<T>::ActualValue(const T & value) : value_(value) {
    }

    template<typename T>
    const ActualValue<T> expect(const T & actualValue) {
        return ActualValue<T>(actualValue);
    }

    template<typename T> template<typename Matcher>
    void ActualValue<T>::to(const Matcher & matcher) const {
        if (!matcher.matches(value_)) {
            [[CDRSpecFailure specFailureWithReason:matcher.failure_message()] raise];
        }
    }

    template<typename T> template<typename Matcher>
    void ActualValue<T>::to_not(const Matcher & matcher) const {
        if (matcher.matches(value_)) {
            [[CDRSpecFailure specFailureWithReason:matcher.negative_failure_message()] raise];
        }
    }
}}
