#import <Foundation/Foundation.h>
#import "CDRExampleBase.h"

#include <iostream>
#include <sstream>

namespace Cedar { namespace Matchers {
    template<typename T>
    class EqualMatcher {
    private:
        EqualMatcher<T> & operator=(const EqualMatcher<T> &);

    public:
        EqualMatcher(const T & expectedValue);
        ~EqualMatcher();
        // Allow default copy ctor.

        template<typename U>
        bool matches(const U &) const;
        bool matches(const id &) const;
        bool matches(NSObject * const &) const;
        bool matches(NSString * const &) const;

        NSString * failure_message() const;
        NSString * negative_failure_message() const;

    private:
        template<typename U>
        NSString * stringFor(const U &) const;
        NSString * stringFor(const id & value) const;
        NSString * stringFor(NSObject * const &) const;
        NSString * stringFor(NSString * const &) const;

    private:
        const T & expectedValue_;
        mutable NSString *actualValueString_;
    };

    template<typename T>
    EqualMatcher<T> equal(const T & expectedValue) {
        return EqualMatcher<T>(expectedValue);
    }

    template<typename T>
    EqualMatcher<T>::EqualMatcher(const T & expectedValue)
    : expectedValue_(expectedValue), actualValueString_(nil) {
    }

    template<typename T>
    EqualMatcher<T>::~EqualMatcher() {
        [actualValueString_ release]; actualValueString_ = nil;
    }

#pragma mark Generic
    template<typename T> template<typename U>
    bool EqualMatcher<T>::matches(const U & actualValue) const {
        actualValueString_ = [this->stringFor(actualValue) retain];
        return expectedValue_ == actualValue;
    }

    template<typename T> template<typename U>
    NSString * EqualMatcher<T>::stringFor(const U & value) const {
        std::stringstream temp;
        temp << value;
        return [NSString stringWithCString:temp.str().c_str() encoding:NSUTF8StringEncoding];
    }

    template<typename T>
    NSString * EqualMatcher<T>::failure_message() const {
        return [NSString stringWithFormat:@"Expected <%@> to equal <%@>", actualValueString_, this->stringFor(expectedValue_)];
    }

    template<typename T>
    NSString * EqualMatcher<T>::negative_failure_message() const {
        return [NSString stringWithFormat:@"Expected <%@> to not equal <%@>", actualValueString_, this->stringFor(expectedValue_)];
    }

#pragma mark id
    template<typename T>
    bool EqualMatcher<T>::matches(const id & actualValue) const {
        actualValueString_ = [[NSString alloc] initWithFormat:@"%@", actualValue];
        return [actualValue isEqual:expectedValue_];
    }

    template<> template<typename U>
    bool EqualMatcher<id>::matches(const U & actualValue) const {
        [[CDRSpecFailure specFailureWithReason:@"Attempt to compare id to incomparable type"] raise];
    }

    template<typename T>
    NSString * EqualMatcher<T>::stringFor(const id & value) const {
        return [NSString stringWithFormat:@"%@", value];
    }

#pragma mark NSObject
    template<typename T>
    bool EqualMatcher<T>::matches(NSObject * const & actualValue) const {
        return this->matches(static_cast<const id &>(actualValue));
    }

    template<> template<typename U>
    bool EqualMatcher<NSObject *>::matches(const U & actualValue) const {
        [[CDRSpecFailure specFailureWithReason:@"Attempt to compare NSObject * to incomparable type"] raise];
    }

    template<typename T>
    NSString * EqualMatcher<T>::stringFor(NSObject * const & value) const {
        return this->stringFor(static_cast<const id &>(value));
    }

#pragma mark NSString
    template<typename T>
    bool EqualMatcher<T>::matches(NSString * const & actualValue) const {
        return this->matches(static_cast<const id &>(actualValue));
    }

    template<> template<typename U>
    bool EqualMatcher<NSString *>::matches(const U & actualValue) const {
        [[CDRSpecFailure specFailureWithReason:@"Attempt to compare NSString * to incomparable type"] raise];
    }

    template<typename T>
    NSString * EqualMatcher<T>::stringFor(NSString * const & value) const {
        return this->stringFor(static_cast<const id &>(value));
    }
}}
