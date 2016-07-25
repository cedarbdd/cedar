#import <Foundation/Foundation.h>
#import "Cedar.h"

@interface CedarTestSpecBuilder : CDRSpec

- (void)wrapWithDeclareBehaviors:(dispatch_block_t)block;

@end
