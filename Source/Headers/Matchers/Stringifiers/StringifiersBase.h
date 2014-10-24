#import <Foundation/Foundation.h>
#include <sstream>

namespace Cedar { namespace Matchers { namespace Stringifiers {
    NSString * object_description_for(const void *objectValue);

    template<typename U>
    NSString * string_for(const U & value) {
        if (0 == strncmp(@encode(U), "@", 1)) {
            return object_description_for(&value);
        } else {
            std::stringstream temp;
            temp << value;
            return [NSString stringWithCString:temp.str().c_str() encoding:NSUTF8StringEncoding];
        }
    }

    inline NSString * string_for(std::nullptr_t value) {
        return @"nil";
    }

    inline NSString * string_for(const char value) {
        return string_for(static_cast<const int>(value));
    }

    inline NSString * string_for(const Class & value) {
        return NSStringFromClass(value);
    }

    inline NSString * string_for(const BOOL value) {
        return value ? @"YES" : @"NO";
    }

    inline NSString * string_for(NSNumber * const value) {
        if (!value) {
            return [NSString stringWithFormat:@"%@", value];
        }

        return string_for([value floatValue]);
    }

    inline NSString * string_for(const NSDecimal value) {
        return NSDecimalString(&value, [NSLocale systemLocale]);
    }

    inline NSString * string_for(char *value) {
        if (value == NULL) {
            return @"NULL";
        }
        return [NSString stringWithFormat:@"cstring(%s)", value];
    }

    inline NSString * string_for(const char *value) {
        return string_for((char *)value);
    }

    inline NSString * string_for(NSRange value) {
        return NSStringFromRange(value);
    }

    inline NSString * string_for(NSDate *date) {
        return [NSString stringWithFormat:@"%@ (%f)", date, [date timeIntervalSince1970]];
    }
}}}
