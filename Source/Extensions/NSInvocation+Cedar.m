#import "NSInvocation+Cedar.h"
#import "NSMethodSignature+Cedar.h"
#import "CDRBlockHelper.h"
#import <objc/runtime.h>

static char COPIED_BLOCKS_KEY;

@interface NSInvocation (UndocumentedPrivate)
- (void)invokeUsingIMP:(IMP)imp;
@end

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

- (NSInvocation *)invocationWithoutCmdArgument {
    NSMethodSignature *methodSignature = [self methodSignature];
    NSMethodSignature *adjustedMethodSignature = [methodSignature signatureWithoutSelectorArgument];
    NSInvocation *adjustedInvocation = [NSInvocation invocationWithMethodSignature:adjustedMethodSignature];

    NSInteger adjustedArgIndex = 0;
    for (NSInteger argIndex=0; argIndex<[methodSignature numberOfArguments]; argIndex++) {
        if (argIndex==1) { continue; }

        NSUInteger size;
        NSGetSizeAndAlignment([methodSignature getArgumentTypeAtIndex:argIndex], &size, NULL);
        char argBuffer[size];

        [self getArgument:argBuffer atIndex:argIndex];
        [adjustedInvocation setArgument:argBuffer atIndex:adjustedArgIndex];

        adjustedArgIndex++;
    }

    return adjustedInvocation;
}

- (void)invokeUsingBlockWithoutSelfArgument:(id)block {
    NSInvocation *adjustedInvocation = [self invocationWithoutCmdArgument];

    [adjustedInvocation setTarget:block];
    struct Block_literal *blockLiteral = (struct Block_literal *)block;
    [adjustedInvocation invokeUsingIMP:(IMP)blockLiteral->invoke];

    NSUInteger returnValueSize = [[self methodSignature] methodReturnLength];
    if (returnValueSize > 0) {
        char returnValueBuffer[returnValueSize];
        [adjustedInvocation getReturnValue:&returnValueBuffer];
        [self setReturnValue:&returnValueBuffer];
    }
}

@end
