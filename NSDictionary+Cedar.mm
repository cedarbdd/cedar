#import "NSObject+Cedar.h"
#import "StringifiersBase.h"

@implementation NSDictionary (Cedar)

- (NSString *)CDR_description {
    NSMutableString *result = [NSMutableString stringWithString:@"@{"];
    BOOL first = YES;
    for (id key in self.allKeys){
        if (!first){
            [result appendString:@","];
            first = YES;
        }

        NSString *stringKey = Cedar::Matchers::Stringifiers::string_for(key);
        NSString *stringValue = Cedar::Matchers::Stringifiers::string_for(self[key]);
        [result appendFormat:@"\n    %@: %@", stringKey, stringValue];
    }
    [result appendString:@"\n]"];
    return result;
}

@end