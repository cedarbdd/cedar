#import "NSObject+Cedar.h"
#import "StringifiersBase.h"

@implementation NSNumber (Cedar)

- (NSString *)CDR_description {
    return [NSString stringWithFormat:@"@%@", Cedar::Matchers::Stringifiers::string_for([self floatValue])];
}

@end