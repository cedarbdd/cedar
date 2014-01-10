#import "MethodStringifierHelper.h"

namespace Cedar { namespace Matchers { namespace Stringifiers {

    NSString * string_for_argument_invocation(NSInvocation *invocation, NSUInteger argumentIndex) {
        const char *type = [invocation.methodSignature getArgumentTypeAtIndex:argumentIndex];

        // yes, the 'larger' types need to be enumerated for
        // ios-simulator support.
        switch (type[0]) {
            case '@':
            case '#': {
                id obj = nil;
                [invocation getArgument:&obj atIndex:argumentIndex];
                if ([obj isKindOfClass:NSClassFromString(@"Protocol")]) {
                    return [NSString stringWithFormat:@"@protocol(%@)", NSStringFromProtocol(obj)];
                }
                return [obj description];
            }
            case ':': {
                SEL sel;
                [invocation getArgument:&sel atIndex:argumentIndex];
                return NSStringFromSelector(sel);
            }
            case 'c': {
                char c = 0;
                [invocation getArgument:&c atIndex:argumentIndex];
                return [NSString stringWithFormat:@"%c", c];
            }
            case 's':
            case 'i':
            case 'l':
            case 'q': {
                long long i = 0;
                [invocation getArgument:&i atIndex:argumentIndex];
                return [NSString stringWithFormat:@"%lld", i];
            }
            case 'C':
            case 'S':
            case 'I':
            case 'L':
            case 'Q': {
                unsigned long long i = 0;
                [invocation getArgument:&i atIndex:argumentIndex];
                return [NSString stringWithFormat:@"%llu", i];
            }
            case 'f':
            case 'd': {
                double value = 0;
                [invocation getArgument:&value atIndex:argumentIndex];
                return [NSString stringWithFormat:@"%f", value];
            }
            case 'B': {
                BOOL boolean = NO;
                [invocation getArgument:&boolean atIndex:argumentIndex];
                return boolean ? @"YES" : @"NO";
            }
            case '*': {
                char *str = NULL;
                [invocation getArgument:&str atIndex:argumentIndex];
                return [NSString stringWithFormat:@"%s", str];
            }
            case '?':
            case '^':
            case 'v': {
                void *ptr = NULL;
                [invocation getArgument:&ptr atIndex:argumentIndex];
                return [NSString stringWithFormat:@"%p", ptr];
            }

            default:
                [NSException raise:NSInternalInconsistencyException format:@"encoding type unsupported: '%s'", type];
                return NULL;
        }
    }

    NSString * string_for_method_invocation(SEL selector, NSArray *argumentStrings) {
        NSString *selectorString = NSStringFromSelector(selector);
        NSArray *components = [selectorString componentsSeparatedByString:@":"];
        BOOL hasAtLeastOneArg = [selectorString rangeOfString:@":"].location != NSNotFound;
        NSMutableString *result = [NSMutableString string];
        NSUInteger numberOfArguments = (hasAtLeastOneArg ? components.count - 1 : 0);
        for (NSUInteger i=0; i<numberOfArguments; i++) {
            NSString *methodNameFragment = [components objectAtIndex:i];
            NSString *argumentValue = @"";
            if (argumentStrings.count > i) {
                argumentValue = [argumentStrings objectAtIndex:i];
            }
            if (argumentValue.length) {
                argumentValue = [NSString stringWithFormat:@"%@ ", argumentValue];
            }
            [result appendFormat:@"%@:%@", methodNameFragment, argumentValue];
        }
        [result appendString:components.lastObject];
        return [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }

    NSString * string_for_method_invocation(NSInvocation *invocation) {
        NSMutableArray *argumentStrings = [NSMutableArray array];
        NSUInteger argumentsOffset = 2;
        NSUInteger numberOfArguments = invocation.methodSignature.numberOfArguments;
        for (NSUInteger i=argumentsOffset; i<numberOfArguments; i++) {
            NSString *value = string_for_argument_invocation(invocation, i);
            [argumentStrings addObject:value];
        }
        return string_for_method_invocation(invocation.selector, argumentStrings);
    }\
}}}
