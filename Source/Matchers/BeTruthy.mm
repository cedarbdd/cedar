#include "BeTruthy.h"

namespace Cedar { namespace Matchers {

    BeTruthy be_truthy() {
        return BeTruthy();
    }

    BeTruthy::BeTruthy() : Base() {
    }

    BeTruthy::~BeTruthy() {
    }

    /*virtual*/ NSString *
    BeTruthy::failure_message_end() const {
        return @"evaluate to true";
    }

}}
