#import "DeallocNotifier.h"

@interface DeallocNotifier ()
@property (nonatomic, copy) void (^notificationBlock)(void);
@end

@implementation DeallocNotifier

- (instancetype)initWithNotificationBlock:(void (^)(void))block {
    if (self = [super init]) {
        self.notificationBlock = block;
    }
    return self;
}

- (void)dealloc {
    self.notificationBlock();
    self.notificationBlock = (id)[NSNull null];
    [super dealloc];
}

@end
