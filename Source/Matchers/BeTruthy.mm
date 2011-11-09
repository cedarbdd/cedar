#include "BeTruthy.h"

namespace Cedar { namespace Matchers {

    // For backwards compatible parenthesis syntax
    const BeTruthy & BeTruthy::operator()() const {
        return *this;
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
