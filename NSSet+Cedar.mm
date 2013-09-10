#import "NSObject+Cedar.h"
#import "StringifiersBase.h"
#import <objc/runtime.h>

@implementation NSSet (Cedar)

- (NSString *)CDR_description {
    NSMutableString *result = [NSMutableString stringWithString:@"[NSSet setWithObjects:"];
    BOOL first = YES;
    for (id item in self){
        if (!first){
            [result appendString:@","];
        }
        first = NO;

        NSString *string = Cedar::Matchers::Stringifiers::string_for(item);
        [result appendFormat:@"\n    %@", string];
    }
    if (!first){
        [result appendString:@","];
    }
    [result appendString:@"\nnil]"];
    return result;
}

@end
