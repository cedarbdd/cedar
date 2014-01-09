#import <Foundation/Foundation.h>

@protocol SimpleMultiplier<NSObject>

- (void)multiplyBy:(NSInteger)amount;
- (void)multiplyByNumber:(NSNumber *)number;

@end
