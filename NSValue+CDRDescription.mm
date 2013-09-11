#import "NSValue+CDRDescription.h"
#import "StringifiersBase.h"
#import <objc/runtime.h>
#import <sstream>

@implementation NSValue (Cedar)

- (NSString *)CDR_description {
    NSMutableString *result = [NSMutableString stringWithString:@"@("];
    const char *objctype = self.objCType;
    if (0 == strcmp(objctype, @encode(NSObject))){
        [result appendString:Cedar::Matchers::Stringifiers::string_for(self.nonretainedObjectValue)];
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
