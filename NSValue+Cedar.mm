#import "NSObject+Cedar.h"
#import "StringifiersBase.h"
#import <objc/runtime.h>
#import <sstream>

@implementation NSValue (Cedar)

- (NSString *)CDR_description {
    NSMutableString *result = [NSMutableString stringWithString:@"@("];
    const char *objctype = self.objCType;
    if (0 == strcmp(objctype, @encode(NSObject))){
        id value = self.nonretainedObjectValue;
        if ([value respondsToSelector:@selector(CDR_description)]) {
            [result appendString:[value CDR_description]];
        } else {
            [result appendString:[value description]];
        }
    } else if (0 == strcmp(objctype, @encode(Class))) {
        [result appendFormat:@"<%@>", NSStringFromClass(*((Class *)self.pointerValue))];
    } else if (0 == strcmp(objctype, @encode(float))) {
        float value;
        [self getValue:&value];
        [result appendString:Cedar::Matchers::Stringifiers::string_for(value)];
    } else {
        [result appendString:[self description]];
    }
    [result appendString:@")"];
    return result;
}

@end
