#include "BeInstanceOf.h"

namespace Cedar { namespace Matchers {

    BeInstanceOf be_instance_of(const Class expectedValue) {
        return BeInstanceOf(expectedValue);
    }

    BeInstanceOf::BeInstanceOf(const Class expectedClass)
    : Base(), expectedClass_(expectedClass), includeSubclasses_(false) {
    }

    BeInstanceOf::~BeInstanceOf() {
    }

    BeInstanceOf & BeInstanceOf::or_any_subclass() {
        includeSubclasses_ = true;
        return *this;
    }

    /*virtual*/ NSString * BeInstanceOf::failure_message_end() const {
        NSMutableString *messageEnd = [NSMutableString stringWithFormat:@"be an instance of class <%@>", expectedClass_];
        if (includeSubclasses_) {
            [messageEnd appendString:@", or any of its subclasses"];
        }
        return messageEnd;
    }

}}
