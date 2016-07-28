#import "CedarTestSpecBuilder.h"

@interface CedarTestSpecBuilder ()
@property dispatch_block_t block;
@end

@implementation CedarTestSpecBuilder

- (void)wrapWithDeclareBehaviors:(dispatch_block_t)block {
    self.block = block;
}

- (void)declareBehaviors {
    if (self.block) {
        self.block();
    }
}

@end
