#import <Foundation/Foundation.h>
#import "CDRSpecFailure.h"

#include <iostream>
#include <sstream>

namespace Cedar { namespace Matchers {

    void fail(const NSString * failureMessage);

    template<typename T> class ActualValue;

#pragma mark class ActualValueMatchProxy
    template<typename T>
    class ActualValueMatchProxy {
    private:
        template<typename U>
        ActualValueMatchProxy(const ActualValueMatchProxy<U> &);
        template<typename U>
        ActualValueMatchProxy & operator=(const ActualValueMatchProxy<U> &);

    public:
        explicit ActualValueMatchProxy(const ActualValue<T> &, bool negate = false);
        ActualValueMatchProxy();

        template<typename Matcher> void operator()(const Matcher &) const;
        ActualValueMatchProxy<T> negate() const;

    private:
        const ActualValue<T> & actualValue_;
        bool negate_;
    };

    template<typename T>
    ActualValueMatchProxy<T>::ActualValueMatchProxy(const ActualValue<T> & actualValue, bool negate /*= false */) : actualValue_(actualValue), negate_(negate) {
    }

    template<typename T> template<typename Matcher>
    void ActualValueMatchProxy<T>::operator()(const Matcher & matcher) const {
        if (negate_) {
            actualValue_.execute_negative_match(matcher);
        } else {
            actualValue_.execute_positive_match(matcher);
        }
    }

    template<typename T>
    ActualValueMatchProxy<T> ActualValueMatchProxy<T>::negate() const {
        return ActualValueMatchProxy<T>(actualValue_, !negate_);
    }

#pragma mark class ActualValue
    template<typename T>
    class ActualValue {
    private:
        template<typename U>
        ActualValue(const ActualValue<U> &);
        template<typename U>
        ActualValue & operator=(const ActualValue<U> &);

    public:
        explicit ActualValue(const char *, int, const T &);
        ~ActualValue();

        ActualValueMatchProxy<T> to;
        ActualValueMatchProxy<T> to_not;

    private:
        template<typename Matcher> void execute_positive_match(const Matcher &) const;
        template<typename Matcher> void execute_negative_match(const Matcher &) const;
        friend class ActualValueMatchProxy<T>;

    private:
        const T value_;
        NSString *fileName_;
        int lineNumber_;
    };

    template<typename T>
    ActualValue<T>::ActualValue(const char *fileName, int lineNumber, const T & value) : lineNumber_(lineNumber), value_(value), to(*this), to_not(*this, true) {
        fileName_ = [[NSString alloc] initWithUTF8String:fileName];
    }

    template<typename T>
    ActualValue<T>::~ActualValue() {
        [fileName_ release];
        fileName_ = nil;
    }

    template<typename T>
    const ActualValue<T> CDR_expect(const char *fileName, int lineNumber, const T & actualValue) {
        return ActualValue<T>(fileName, lineNumber, actualValue);
    }

    template<typename T> template<typename Matcher>
    void ActualValue<T>::execute_positive_match(const Matcher & matcher) const {
        if (!matcher.matches(value_)) {
            [[CDRSpecFailure specFailureWithReason:matcher.failure_message() fileName:fileName_ lineNumber:lineNumber_] raise];
        }
    }

    template<typename T> template<typename Matcher>
    void ActualValue<T>::execute_negative_match(const Matcher & matcher) const {
        if (matcher.matches(value_)) {
            [[CDRSpecFailure specFailureWithReason:matcher.negative_failure_message() fileName:fileName_ lineNumber:lineNumber_] raise];
        }
    }

}}

#ifndef CEDAR_MATCHERS_COMPATIBILITY_MODE
    #define expect(x) CDR_expect(__FILE__, __LINE__, x)
#endif
