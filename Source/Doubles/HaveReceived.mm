#import "HaveReceived.h"
#import "NSInvocation+Cedar.h"

namespace Cedar { namespace Doubles {

    NSString * recorded_invocations_message(NSArray *recordedInvocations) {
        NSMutableString *message = [NSMutableString string];

        for (NSInvocation *invocation in recordedInvocations) {
            [message appendFormat:@"  %@", NSStringFromSelector(invocation.selector)];
            NSArray *arguments = [invocation cdr_arguments];
            if (arguments.count) {
                [message appendFormat:@"<%@>", [arguments componentsJoinedByString:@", "]];
            }
            [message appendString:@"\n"];
        }

        return message;
    }
}}
