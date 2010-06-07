#import <Foundation/Foundation.h>
#import "CDRExampleBase.h"

#include <iostream>
#include <sstream>

namespace Cedar {
namespace Matchers {

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

    inline void foo(int i) const { std::cout << "int foo" << std::endl; }
    inline void foo(NSObject * i) const { std::cout << "NSObject foo" << std::endl; };

    template<typename U>
    inline void bar(U i) const { std::cout << "template bar" << std::endl; }

private:
    const T value_;
};

#pragma mark It's 2010 and linkers still can't handle templates in implementation files?

template<typename T>
const ActualValue<T> expect(const T & value) {
    return ActualValue<T>(value);
}

template<typename T>
ActualValue<T>::ActualValue(const T & value) : value_(value) {
}

#pragma mark toEqual
template<typename T> template<typename U>
void ActualValue<T>::toEqual(const U & expectedValue) const {
    if (expectedValue != value_) {
        std::stringstream message;
        message << "Expected <" << value_ << "> to equal <" << expectedValue << ">";

        [[CDRSpecFailure specFailureWithReason:[NSString stringWithCString:message.str().c_str() encoding:NSUTF8StringEncoding]] raise];
    }
}

}
}
