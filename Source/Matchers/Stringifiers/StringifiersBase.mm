#import "StringifiersBase.h"
#import <objc/runtime.h>

@protocol CDRExplicitDescription //informal
- (NSString *)cdr_explicitDescription;
@end

static char *CDRUseExplicitDescriptionKey;

namespace Cedar { namespace Matchers { namespace Stringifiers {
    NSString * object_description_for(const void *objectValue) {
        NSValue *valueId = [NSValue valueWithBytes:objectValue objCType:@encode(id)];
        id object = [valueId nonretainedObjectValue];
        Class klass = object_getClass(object);
        if ([objc_getAssociatedObject(object, &CDRUseExplicitDescriptionKey) boolValue]) {
            return [NSString stringWithFormat:@"%@", [[valueId nonretainedObjectValue] cdr_explicitDescription]];
        } else if (object && class_getInstanceMethod(klass, @selector(description)) == NULL) {
            return [NSString stringWithFormat:@"%@ %p", NSStringFromClass(klass), object];
        } else {
            return [NSString stringWithFormat:@"%@", [[valueId nonretainedObjectValue] description]];
        }
    }

    void attempt_future_explication(const void *objectValue) {
        NSValue *valueId = [NSValue valueWithBytes:objectValue objCType:@encode(id)];
        id object = [valueId nonretainedObjectValue];
        Class klass = object_getClass(object);
        if (class_getInstanceMethod(klass, @selector(cdr_explicitDescription))) {
            objc_setAssociatedObject(object, &CDRUseExplicitDescriptionKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}}}
