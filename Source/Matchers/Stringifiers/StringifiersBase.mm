#import "StringifiersBase.h"
#import <objc/runtime.h>

namespace Cedar { namespace Matchers { namespace Stringifiers {
    NSString * object_description_for(const void *objectValue) {
        NSValue *valueId = [NSValue valueWithBytes:objectValue objCType:@encode(id)];
        id object = [valueId nonretainedObjectValue];
        Class klass = object_getClass(object);
        if (object && class_getInstanceMethod(klass, @selector(description)) == NULL) {
            return [NSString stringWithFormat:@"%@ %p", NSStringFromClass(klass), object];
        } else {
            return [NSString stringWithFormat:@"%@", [[valueId nonretainedObjectValue] description]];
        }
    }
}}}
