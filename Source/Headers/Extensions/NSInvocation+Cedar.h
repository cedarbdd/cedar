#import <Foundation/Foundation.h>

@interface NSInvocation (Cedar)

- (void)copyBlockArguments;
- (NSInvocation *)invocationWithoutCmdArgument;
- (void)invokeUsingBlockWithoutSelfArgument:(id)block;

- (NSArray *)arguments;

@end
