#import "NSInvocation+Cedar.h"
#import <objc/runtime.h>

@implementation NSInvocation (Cedar)

- (void)copyBlockArguments {
    static char *blockTypeEncoding = "@?";
    NSMethodSignature *methodSignature = [self methodSignature];
    NSUInteger numberOfArguments = [methodSignature numberOfArguments];
    NSMutableArray *copiedBlocks = [NSMutableArray array];

    for (NSUInteger argumentIndex = 2; argumentIndex < numberOfArguments; ++argumentIndex) {
        const char *encoding = [methodSignature getArgumentTypeAtIndex:argumentIndex];
        if (strncasecmp(blockTypeEncoding, encoding, 2) == 0) {
            id argument = nil;
            [self getArgument:&argument atIndex:argumentIndex];
            if (argument) {
                argument = [argument copy];
                [copiedBlocks addObject:(id)argument];
                [argument release];
                [self setArgument:&argument atIndex:argumentIndex];
            }
        }
    }

    objc_setAssociatedObject(self, @"copied-blocks", copiedBlocks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
