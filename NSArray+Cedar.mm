#import "NSObject+Cedar.h"
#import "StringifiersBase.h"
#import <objc/runtime.h>

@implementation NSArray (Cedar)

- (NSString *)CDR_description {
    NSMutableString *result = [NSMutableString stringWithString:@"@["];
    BOOL first = YES;
    for (id item in self){
        if (!first){
            [result appendString:@","];
            first = YES;
        }

        NSString *string = Cedar::Matchers::Stringifiers::string_for(item);
        [result appendFormat:@"\n    %@", string];
    }
    [result appendString:@"\n]"];
    return result;
}

@end
