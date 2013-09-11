#import "NSString+CDRDescription.h"
#import "StringifiersBase.h"

@implementation NSString (Cedar)

- (NSString *)CDR_description {
    return [NSString stringWithFormat:@"@\"%@\"", Cedar::Matchers::Stringifiers::escape_as_string(self)];
}

@end

@implementation NSMutableString (Cedar)

- (NSString *)CDR_description {
    return [NSString stringWithFormat:@"@\"%@\"", Cedar::Matchers::Stringifiers::escape_as_string(self)];
}

@end