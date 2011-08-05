#import "Base.h"

namespace Cedar { namespace Matchers {
    Base::Base() : failureMessageStart_(nil) {
    }

    Base::~Base() {
        [failureMessageStart_ release]; failureMessageStart_ = nil;
    }

    NSString * Base::failure_message() const {
        return [NSString stringWithFormat:@"Expected <%@> to %@", failureMessageStart_, this->failure_message_end()];
    }

    NSString * Base::negative_failure_message() const {
        return [NSString stringWithFormat:@"Expected <%@> to not %@", failureMessageStart_, this->failure_message_end()];
    }
}}
