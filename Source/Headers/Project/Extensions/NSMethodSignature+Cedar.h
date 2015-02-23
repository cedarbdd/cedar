#import <Foundation/Foundation.h>

@interface NSMethodSignature (Cedar)

+ (NSMethodSignature *)signatureFromBlock:(id)block;
- (NSMethodSignature *)signatureWithoutSelectorArgument;

@end
