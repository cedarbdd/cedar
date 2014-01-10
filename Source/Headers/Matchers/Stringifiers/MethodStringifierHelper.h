#import <Foundation/Foundation.h>

namespace Cedar { namespace Matchers { namespace Stringifiers {
    NSString * string_for_method_invocation(SEL, NSArray *);
    NSString * string_for_method_invocation(NSInvocation *i);
}}}
