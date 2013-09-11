#import "NSDictionary+CDRDescription.h"
#import "StringifiersBase.h"

@implementation NSDictionary (Cedar)

- (NSString *)CDR_description {
    NSMutableString *result = [NSMutableString stringWithString:@"@{"];
    NSString *pairFormat = @"\n    %@: %@";
    NSString *terminator = @"\n}";
    if (self.count < 2) {
        pairFormat = @"%@: %@";
        terminator = @"}";
    }
    BOOL first = YES;
    for (id key in self.allKeys){
        if (!first){
            [result appendString:@","];
        }
        first = NO;

        NSString *stringKey = Cedar::Matchers::Stringifiers::string_for(key);
        NSString *stringValue = Cedar::Matchers::Stringifiers::string_for(self[key]);
        [result appendFormat:pairFormat, stringKey, stringValue];
    }
    [result appendString:terminator];
    return result;
}

@end