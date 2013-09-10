#import <Foundation/Foundation.h>

// interface for any NSObject to support stringifiers
@interface NSObject (Cedar)

- (NSString *)CDR_description;

@end
