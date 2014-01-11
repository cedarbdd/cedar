#import "NSInvocation+Cedar.h"
#import <objc/runtime.h>

static char COPIED_BLOCKS_KEY;

@implementation NSInvocation (Cedar)

- (void)copyBlockArguments {
    static char *blockTypeEncoding = "@?";
    NSMethodSignature *methodSignature = [self methodSignature];
    NSUInteger numberOfArguments = [methodSignature numberOfArguments];
    NSMutableArray *copiedBlocks = [NSMutableArray array];

    for (NSUInteger argumentIndex = 2; argumentIndex < numberOfArguments; ++argumentIndex) {
        const char *encoding = [methodSignature getArgumentTypeAtIndex:argumentIndex];
        if (strncmp(blockTypeEncoding, encoding, 2) == 0) {
            id argument = nil;
            [self getArgument:&argument atIndex:argumentIndex];
            if (argument) {
                argument = [argument copy];
                [copiedBlocks addObject:argument];
                [argument release];
                [self setArgument:&argument atIndex:argumentIndex];
            }
        }
    }

    objc_setAssociatedObject(self, &COPIED_BLOCKS_KEY, copiedBlocks, OBJC_ASSOCIATION_RETAIN);
}

@end
