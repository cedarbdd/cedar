#import "SimpleIncrementer.h"

@interface SimpleIncrementer ()
@property (nonatomic, assign) size_t value;
@end

@implementation IncrementerBase

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

- (void)incrementByInteger:(NSUInteger)integer {
    self.value += integer;
}

- (void)incrementByABit:(size_t)aBit andABitMore:(NSNumber *)aBitMore {
    self.value += aBit + [aBitMore intValue];
}

- (void)incrementWithException {
    [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"wibble" userInfo:nil] raise];
}

- (void)methodWithBlock:(void(^)())blockArgument {
}

- (void)methodWithCString:(char *)string {
}

- (NSNumber *)methodWithNumber1:(NSNumber *)arg1 andNumber2:(NSNumber *)arg2 {
    return @([arg1 floatValue] * [arg2 floatValue]);
}

- (double)methodWithDouble1:(double)double1 andDouble2:(double)double2 {
    return double1*double2;
}

- (LargeIncrementerStruct)methodWithLargeStruct1:(LargeIncrementerStruct)struct1 andLargeStruct2:(LargeIncrementerStruct)struct2 {
    return (LargeIncrementerStruct){};
}

@end
