#import <Foundation/Foundation.h>

@protocol SimpleIncrementer<NSObject>

- (size_t)value;
- (void)increment;
- (void)incrementBy:(size_t)amount;
- (void)incrementByNumber:(NSNumber *)number;
- (void)incrementByABit:(size_t)aBit andABitMore:(NSNumber *)aBitMore;
- (void)incrementWithException;

@end

@interface SimpleIncrementer : NSObject<SimpleIncrementer>

@end
