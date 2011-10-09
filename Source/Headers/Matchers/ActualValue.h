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
        explicit ActualValue(const char *, int, const T &);
        ~ActualValue();

        template<typename Matcher> void to(const Matcher &) const;
        template<typename Matcher> void to_not(const Matcher &) const;

    private:
        const T value_;
        NSString *fileName_;
        int lineNumber_;
    };

    template<typename T>
    ActualValue<T>::ActualValue(const char *fileName, int lineNumber, const T & value) : lineNumber_(lineNumber), value_(value) {
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

    #ifndef CEDAR_MATCHERS_COMPATIBILITY_MODE
        #define expect(x) CDR_expect(__FILE__, __LINE__, x)
    #endif

    template<typename T> template<typename Matcher>
    void ActualValue<T>::to(const Matcher & matcher) const {
        if (!matcher.matches(value_)) {
            [[CDRSpecFailure specFailureWithReason:matcher.failure_message() fileName:fileName_ lineNumber:lineNumber_] raise];
        }
    }

    template<typename T> template<typename Matcher>
    void ActualValue<T>::to_not(const Matcher & matcher) const {
        if (matcher.matches(value_)) {
            [[CDRSpecFailure specFailureWithReason:matcher.negative_failure_message() fileName:fileName_ lineNumber:lineNumber_] raise];
        }
    }
}}
