#import "StringifiersBase.h"
#import "NSValue+CDRDescription.h"
#import <objc/runtime.h>

namespace Cedar { namespace Matchers { namespace Stringifiers {
    NSString * object_description_for(const void *objectValue) {
        NSValue *valueId = [NSValue valueWithBytes:objectValue objCType:@encode(id)];
        id object = [valueId nonretainedObjectValue];
        Class klass = object_getClass(object);
        if (object && class_getInstanceMethod(klass, @selector(CDR_description)) != NULL) {
            return [[valueId nonretainedObjectValue] CDR_description];
        } else if (object && class_getInstanceMethod(klass, @selector(description)) == NULL) {
            return [NSString stringWithFormat:@"<%@ %p>", NSStringFromClass(klass), object];
        } else {
            return [[valueId nonretainedObjectValue] description];
        }
    }

    NSString * escape_as_string(const NSString * str) {
        NSMutableString *mutableString = [str mutableCopy];
        [mutableString replaceOccurrencesOfString:@"\t" withString:@"\\t" options:0 range:NSMakeRange(0, mutableString.length)];
        [mutableString replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:0 range:NSMakeRange(0, mutableString.length)];
        return mutableString;
    }

    NSString * escape_as_string(const char * str) {
        return escape_as_string([NSString stringWithCString:str encoding:NSUTF8StringEncoding]);
    }
}}}
