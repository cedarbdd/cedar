#import "HaveReceived.h"
#import "CedarDouble.h"
#import "NSInvocation+Cedar.h"
#import "MethodStringifierHelper.h"
#import <objc/runtime.h>

namespace Cedar { namespace Doubles {

    HaveReceived::HaveReceived(const SEL expectedSelector)
    : Base<>(), InvocationMatcher(expectedSelector) {
    }

    HaveReceived::~HaveReceived() {
    }

    bool HaveReceived::matches(id instance) const {
        this->verify_object_is_a_double(instance);
        this->verify_count_and_types_of_arguments(instance);

        for (NSInvocation *invocation in [instance sent_messages]) {
            if (this->InvocationMatcher::matches(invocation)) {
                return true;
            }
        }
        return false;
    }

    void HaveReceived::verify_object_is_a_double(id instance) const {
        Class clazz = object_getClass(instance);
        if (![clazz conformsToProtocol:@protocol(CedarDouble)]) {
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"Received expectation for non-double object <%@>", instance]
                                   userInfo:nil]
             raise];
        }
    }

#pragma mark - Protected interface
    /*virtual*/ NSString * HaveReceived::failure_message_end() const {
        NSString *selectorString = NSStringFromSelector(this->selector());
        NSMutableString *message = [NSMutableString stringWithFormat:@"have received message <%@>", selectorString];
        if (this->arguments().size()) {
            [message appendString:@" with arguments <"];
            arguments_vector_t::const_iterator cit = this->arguments().begin();
            [message appendString:(*cit++)->value_string()];
            for (; cit != this->arguments().end(); ++cit) {
                [message appendString:[NSString stringWithFormat:@", %@", (*cit)->value_string()]];
            }
            [message appendString:@">"];
        }
        return message;
    }
    /*virtual*/ NSString * HaveReceived::failure_message_end(id<CedarDouble> cedarDouble) const {
        NSMutableString *message = [this->failure_message_end() mutableCopy];
        if ([cedarDouble sent_messages].count) {
            [message appendString:@", but received:\n"];
            for (NSInvocation *invocation in [cedarDouble sent_messages]) {
                [message appendFormat:@" <%@>", NSStringFromSelector(invocation.selector)];
                if (invocation.methodSignature.numberOfArguments > 2) {
                    [message appendString:@" with arguments <"];
                    [message appendString:Cedar::Matchers::Stringifiers::string_for_argument_invocation(invocation, 2)];
                    for (NSInteger i=3; i<invocation.methodSignature.numberOfArguments; i++) {
                        [message appendFormat:@", %@", Cedar::Matchers::Stringifiers::string_for_argument_invocation(invocation, i)];
                    }
                    [message appendString:@">"];
                }

                [message appendString:@"\n"];
            }
        }
        return message;
    }

#pragma mark -
    HaveReceived have_received(const SEL expectedSelector) {
        return HaveReceived(expectedSelector);
    }

    HaveReceived have_received(const char * expectedMethod) {
        return HaveReceived(NSSelectorFromString([NSString stringWithUTF8String:expectedMethod]));
    }

}}
