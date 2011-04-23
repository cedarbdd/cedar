#import "BeNil.h"

namespace Cedar { namespace Matchers {

    BeNil be_nil() {
        return BeNil();
    }

    BeNil::BeNil() : Base() {
    }

    BeNil::~BeNil() {
    }

    /*virtual*/ NSString * BeNil::failure_message_end() const {
        return @"be nil";
    }

}}
