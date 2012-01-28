#import <Foundation/Foundation.h>

@interface SimpleIncrementer : NSObject

@property (nonatomic, assign) size_t value;

- (void)increment;
- (void)incrementBy:(size_t)amount;
- (void)incrementByNumber:(NSNumber *)number;
- (void)incrementByABit:(size_t)aBit andABitMore:(NSNumber *)aBitMore;
- (void)incrementWithException;

@end
