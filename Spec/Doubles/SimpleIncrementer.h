#import <Foundation/Foundation.h>

@protocol SimpleIncrementer<NSObject>

@required
- (size_t)value;
- (size_t)aVeryLargeNumber;
- (void)increment;
- (void)incrementBy:(size_t)amount;
- (void)incrementByNumber:(NSNumber *)number;
- (void)incrementByABit:(size_t)aBit andABitMore:(NSNumber *)aBitMore;
- (void)incrementWithException;
- (void)methodWithBlock:(void(^)())blockArgument;
- (void)methodWithCString:(char *)string;
- (NSNumber *)methodWithNumber1:(NSNumber *)arg1 andNumber2:(NSNumber *)arg2;

@optional
- (size_t)whatIfIIncrementedBy:(size_t)amount;

@end

@interface SimpleIncrementer : NSObject<SimpleIncrementer>

@end
