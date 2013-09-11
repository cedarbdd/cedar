#import <Foundation/Foundation.h>
#include <sstream>
#import "NSObject+Cedar.h"

namespace Cedar { namespace Matchers { namespace Stringifiers {
    NSString * object_description_for(const void *objectValue);
    NSString * escape_as_string(const NSString *str);
    NSString * escape_as_string(const char *str);

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

    inline NSString * string_for(NSNumber * value) {
        return [value CDR_description]; // @encode(NSNumber*) => f
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

    inline NSString * string_for(const NSDecimal value) {
        return NSDecimalString(&value, [NSLocale currentLocale]);
    }

    inline NSString * string_for(char *value) {
        if (value == NULL) {
            return @"NULL";
        }
        return [NSString stringWithFormat:@"\"%@\"", escape_as_string(value)];
    }

    inline NSString * string_for(const char *value) {
        return string_for((char *)value);
    }
}}}
