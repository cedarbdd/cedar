#import "SimpleIncrementer.h"

@interface SimpleIncrementer ()
@property (nonatomic, assign) size_t value;
@end


@implementation SimpleIncrementer

@synthesize value = value_;

- (void)increment {
    ++self.value;
}

- (size_t)aVeryLargeNumber {
    return 0x7fffffff;
}

- (void)incrementBy:(size_t)amount {
    self.value += amount;
}

- (void)incrementByNumber:(NSNumber *)number {
    self.value += [number intValue];
}

- (void)incrementByABit:(size_t)aBit andABitMore:(NSNumber *)aBitMore {
    self.value += aBit + [aBitMore intValue];
}

- (void)incrementWithException {
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"wibble" userInfo:nil] raise];
}

@end
