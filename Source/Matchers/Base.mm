#import "Base.h"

namespace Cedar { namespace Matchers {

    Base::Base() : valueString_(nil) {
    }

    Base::~Base() {
        [valueString_ release]; valueString_ = nil;
    }

    NSString * Base::string_for(const char value) const {
        return this->string_for(static_cast<const int>(value));
    }

    NSString * Base::string_for(const BOOL value) const {
        return value ? @"YES" : @"NO";
    }

    NSString * Base::string_for(const id value) const {
        return [NSString stringWithFormat:@"%@", value];
    }

    NSString * Base::string_for(NSObject * const value) const {
        return this->string_for(static_cast<const id &>(value));
    }

    NSString * Base::string_for(NSString * const value) const {
        return this->string_for(static_cast<const id &>(value));
    }

    NSString * Base::failure_message() const {
        return [NSString stringWithFormat:@"Expected <%@> to %@", valueString_, this->failure_message_end()];
    }

    NSString * Base::negative_failure_message() const {
        return [NSString stringWithFormat:@"Expected <%@> to not %@", valueString_, this->failure_message_end()];
    }

}}
