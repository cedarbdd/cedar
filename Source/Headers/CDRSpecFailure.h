#import <Foundation/Foundation.h>

@interface CDRSpecFailure : NSException
+ (id)specFailureWithReason:(NSString *)reason;
@end
