#import <Foundation/Foundation.h>

typedef struct {
    size_t a, b, c, d;
} LargeIncrementerStruct;

typedef LargeIncrementerStruct (^ComplexIncrementerBlock)(NSNumber *, LargeIncrementerStruct, id<NSCoding>);

@class FooSuperclass;

@protocol InheritedProtocol<NSObject>
@end

@protocol SimpleIncrementer<InheritedProtocol>

@required
- (size_t)value;
- (size_t)aVeryLargeNumber;
- (NSNumber *)valueAsNumber;
- (void)increment;
- (void)incrementBy:(size_t)amount;
- (void)incrementByNumber:(NSNumber *)number;
- (void)incrementByInteger:(NSUInteger)number;
- (void)incrementByABit:(unsigned int)aBit andABitMore:(NSNumber *)aBitMore;
- (void)incrementWithException;
- (void)methodWithBlock:(void(^)())blockArgument;
- (void)methodWithCString:(char *)string;
- (id)methodWithInheritedProtocol:(id<InheritedProtocol>)protocol;
- (NSString *)methodWithString:(NSString *)string;
- (NSNumber *)methodWithNumber1:(NSNumber *)arg1 andNumber2:(NSNumber *)arg2;
- (double)methodWithDouble1:(double)double1 andDouble2:(double)double2;
- (LargeIncrementerStruct)methodWithLargeStruct1:(LargeIncrementerStruct)struct1 andLargeStruct2:(LargeIncrementerStruct)struct2;
- (void)methodWithNumber:(NSNumber *)number complexBlock:(ComplexIncrementerBlock)block;
- (NSString *)methodWithFooSuperclass:(FooSuperclass *)fooInstance;
- (void)methodWithPrimitivePointerArgument:(int *)arg;
- (void)methodWithObjectPointerArgument:(out id *)anObjectPointer;

@optional
- (size_t)whatIfIIncrementedBy:(size_t)amount;
@end

@interface IncrementerBase : NSObject

@end

@interface SimpleIncrementer : IncrementerBase<SimpleIncrementer>

@property (nonatomic, copy) NSString *string;

@end
