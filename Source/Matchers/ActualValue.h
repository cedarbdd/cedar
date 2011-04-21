#import <Foundation/Foundation.h>
#import "CDRExampleBase.h"

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

        template<typename U>
        void toEqual(const U &) const;

    private:
        const T value_;
    };


    template<typename T>
    const ActualValue<T> expect(const T & value) {
        return ActualValue<T>(value);
    }

    template<typename T>
    ActualValue<T>::ActualValue(const T & value) : value_(value) {
    }

#pragma mark toEqual
    // Generic method must be defined here, not in the implementation file.
    template<typename T> template<typename U>
    void ActualValue<T>::toEqual(const U & expectedValue) const {
        if (expectedValue != value_) {
            std::stringstream message;
            message << "Expected <" << value_ << "> to equal <" << expectedValue << ">";

            [[CDRSpecFailure specFailureWithReason:[NSString stringWithCString:message.str().c_str() encoding:NSUTF8StringEncoding]] raise];
        }
    }

    // Specialized methods must be declared here, but defined in the implementation file.
    // If not declared here, OS X build will fail to pick up the specialization.  If defined
    // here, iOS builds will fail with duplicate symbol link errors.
    template<> template<>
    void ActualValue<NSObject *>::toEqual(NSObject * const & expectedValue) const;
}}
