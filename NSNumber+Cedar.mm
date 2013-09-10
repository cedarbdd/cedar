#import "NSObject+Cedar.h"

@implementation NSNumber (Cedar)

- (NSString *)CDR_description {
    return [NSString stringWithFormat:@"@%@", self];
}

@end