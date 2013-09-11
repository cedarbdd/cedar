#import "NSSet+CDRDescription.h"
#import "StringifiersBase.h"
#import <objc/runtime.h>

@implementation NSSet (Cedar)

- (NSString *)CDR_description {
    NSString *itemFormat = @"\n    %@";
    NSString *prefixTerminator = @",";
    NSString *terminator = @"\nnil]";

    if (self.count == 0) {
        return @"[NSSet set]";
    } else if (self.count < 2) {
        itemFormat = @"%@";
        prefixTerminator = @", ";
        terminator = @"nil]";
    }

    NSMutableString *result = [NSMutableString stringWithString:@"[NSSet setWithObjects:"];

    BOOL first = YES;
    for (id item in self){
        if (!first){
            [result appendString:@","];
        }
        first = NO;

        NSString *string = Cedar::Matchers::Stringifiers::string_for(item);
        [result appendFormat:itemFormat, string];
    }
    if (!first){
        [result appendString:prefixTerminator];
    }
    [result appendString:terminator];
    return result;
}

@end
