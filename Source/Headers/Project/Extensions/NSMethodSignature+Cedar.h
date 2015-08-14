#import <Foundation/Foundation.h>

@interface NSMethodSignature (Cedar)

+ (NSMethodSignature *)cdr_signatureFromBlock:(id)block;
- (NSMethodSignature *)cdr_signatureWithoutSelectorArgument;

@end
