#import "Base.h"

namespace Cedar { namespace Matchers {

    namespace StringConversions {
        NSString * string_for(const char value) {
            return string_for(static_cast<const int>(value));
        }

        NSString * string_for(const BOOL value) {
            return value ? @"YES" : @"NO";
        }

        NSString * string_for(const id value) {
            return [NSString stringWithFormat:@"%@", value];
        }

        NSString * string_for(NSObject * const value) {
            return string_for(static_cast<const id &>(value));
        }

        NSString * string_for(NSString * const value) {
            return string_for(static_cast<const id &>(value));
        }

        NSString * string_for(NSNumber * const value) {
            return string_for([value floatValue]);
        }
    }

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
