#import "BeNil.h"

namespace Cedar { namespace Matchers {

    // For backwards compatible parenthesis syntax
    const BeNil & BeNil::operator()() const {
        return *this;
    }

    BeNil::BeNil() : Base() {
    }

    BeNil::~BeNil() {
    }

    /*virtual*/ NSString * BeNil::failure_message_end() const {
        return @"be nil";
    }

}}
