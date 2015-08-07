#import "NSInvocation+Cedar.h"
#import "NSMethodSignature+Cedar.h"
#import "CDRBlockHelper.h"
#import "CDRTypeUtilities.h"
#import <objc/runtime.h>

static char COPIED_BLOCKS_KEY;

@interface NSInvocation (UndocumentedPrivate)
- (void)invokeUsingIMP:(IMP)imp;
@end

@implementation NSInvocation (Cedar)

- (void)cdr_copyBlockArguments {
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

- (NSInvocation *)cdr_invocationWithoutCmdArgument {
    NSMethodSignature *methodSignature = [self methodSignature];
    NSMethodSignature *adjustedMethodSignature = [methodSignature cdr_signatureWithoutSelectorArgument];
    NSInvocation *adjustedInvocation = [NSInvocation invocationWithMethodSignature:adjustedMethodSignature];

    NSInteger adjustedArgIndex = 0;
    for (NSInteger argIndex = 0; argIndex < [methodSignature numberOfArguments]; argIndex++) {
        if (argIndex == 1) { continue; }

        NSUInteger size;
        NSGetSizeAndAlignment([methodSignature getArgumentTypeAtIndex:argIndex], &size, NULL);
        char argBuffer[size];

        [self getArgument:argBuffer atIndex:argIndex];
        [adjustedInvocation setArgument:argBuffer atIndex:adjustedArgIndex];

        adjustedArgIndex++;
    }

    return adjustedInvocation;
}

- (void)cdr_invokeUsingBlockWithoutSelfArgument:(id)block {
    NSInvocation *adjustedInvocation = [self cdr_invocationWithoutCmdArgument];

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

- (NSArray *)cdr_arguments {
    NSMutableArray *args = [NSMutableArray array];
    NSMethodSignature *methodSignature = [self methodSignature];
    for (NSInteger argIndex = 2; argIndex < [methodSignature numberOfArguments]; argIndex++) {
        NSUInteger size;
        NSGetSizeAndAlignment([methodSignature getArgumentTypeAtIndex:argIndex], &size, NULL);
        char argBuffer[size];
        memset(argBuffer, (int)sizeof(argBuffer), sizeof(char));
        [self getArgument:argBuffer atIndex:argIndex];

        const char *argType = [methodSignature getArgumentTypeAtIndex:argIndex];
        [args addObject:[CDRTypeUtilities boxedObjectOfBytes:argBuffer ofObjCType:argType]];
    }
    return args;
}

@end
