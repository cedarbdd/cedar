#import <Foundation/Foundation.h>

@interface NSInvocation (Cedar)

- (void)cdr_copyBlockArguments;
- (void)cdr_invokeUsingBlockWithoutSelfArgument:(id)block;

- (NSArray *)cdr_arguments;

@end
