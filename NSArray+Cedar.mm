#import "NSObject+Cedar.h"
#import "StringifiersBase.h"
#import <objc/runtime.h>

@implementation NSArray (Cedar)

- (NSString *)CDR_description {
    NSMutableString *result = [NSMutableString stringWithString:@"@["];
    NSString *itemFormat = @"\n    %@";
    NSString *terminator = @"\n]";
    if (self.count < 2) {
        itemFormat = @"%@";
        terminator = @"]";
    }
    BOOL first = YES;
    for (id item in self){
        if (!first){
            [result appendString:@","];
        }
        first = NO;

        NSString *string = Cedar::Matchers::Stringifiers::string_for(item);
        [result appendFormat:itemFormat, string];
    }
    [result appendString:terminator];
    return result;
}

@end
