#import "NSInvocation+Cedar.h"
#import <objc/runtime.h>

@interface StringHolder: NSObject {
    char *_cString;
}
- (id)initWithCString:(char *)cString;
@end

@implementation StringHolder
- (void)dealloc {
    free(_cString);
    [super dealloc];
}

- (id)initWithCString:(char *)cString {
    if (self = [super init]) {
        _cString = cString;
    }
    return self;
}
@end

@implementation NSInvocation (Cedar)

- (void)retainMethodArgumentsAndCopyBlocks {
    NSMethodSignature *methodSignature = [self methodSignature];
    NSUInteger numberOfArguments = [methodSignature numberOfArguments];
    NSMutableArray *retainedArguments = [NSMutableArray arrayWithCapacity:numberOfArguments];

    for (NSUInteger argumentIndex = 2; argumentIndex < numberOfArguments; ++ argumentIndex) {
        const char *encoding = [methodSignature getArgumentTypeAtIndex:argumentIndex];
        void *argument = nil;
        [self getArgument:&argument atIndex:argumentIndex];
        if (argument) {
            if (strlen(encoding) == 2 && strncasecmp("@?", encoding, 2) == 0) {
                argument = [(id)argument copy];
                [retainedArguments addObject:(id)argument];
                [(id)argument release];
                [self setArgument:&argument atIndex:argumentIndex];
            } else if (encoding[0] == '@') {
                [retainedArguments addObject:(id)argument];
            } else if (encoding[0] == '*') {
                size_t stringLength = strlen(argument);
                char *copiedArgument = malloc(stringLength);
                strcpy(copiedArgument, argument);
                [self setArgument:&copiedArgument atIndex:argumentIndex];
                StringHolder *stringHolder = [[StringHolder alloc] initWithCString:argument];
                [retainedArguments addObject:stringHolder];
                [stringHolder release];
            }
        }
    }

    objc_setAssociatedObject(self, @"retained-arguments", retainedArguments, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
