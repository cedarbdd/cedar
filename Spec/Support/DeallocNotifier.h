#import <Foundation/Foundation.h>

@interface DeallocNotifier : NSObject

- (instancetype)initWithNotificationBlock:(void (^)(void))block;

@end
