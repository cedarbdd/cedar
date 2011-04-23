#include "BeTruthy.h"

namespace Cedar { namespace Matchers {

    BeTruthy be_truthy() {
        return BeTruthy();
    }

    BeTruthy::BeTruthy() : Base() {
    }

    BeTruthy::~BeTruthy() {
    }

    NSString * BeTruthy::failure_message() const {
        return [NSString stringWithFormat:@"%@ evaluate to true", this->failure_message_start()];
    }

    NSString * BeTruthy::negative_failure_message() const {
        return [NSString stringWithFormat:@"%@ not evaluate to true", this->failure_message_start()];
    }

}}
