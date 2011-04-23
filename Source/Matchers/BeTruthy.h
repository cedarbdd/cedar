#import <Foundation/Foundation.h>
#import "CDRExampleBase.h"
#import "Base.h"

#include <iostream>
#include <sstream>

namespace Cedar { namespace Matchers {
    class BeTruthy : Base {
    private:
        BeTruthy & operator=(const BeTruthy &);

    public:
        BeTruthy();
        ~BeTruthy();
        // Allow default copy ctor.

        template<typename U>
        bool matches(const U &) const;

        NSString * failure_message() const;
        NSString * negative_failure_message() const;
    };

    BeTruthy be_truthy();

#pragma mark Generic
    template<typename U>
    bool BeTruthy::matches(const U & actualValue) const {
        this->build_failure_message_start(actualValue);
        return !!actualValue;
    }

}}
