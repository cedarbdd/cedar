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
        NSMutableArray *arguments = [NSMutableArray array];
        arguments_vector_t::const_iterator cit = this->arguments().begin();
        for (; cit != this->arguments().end(); ++cit) {
            NSString *value = (*cit)->value_string();
            [arguments addObject:value];
        }
        NSString *methodSignatureString = Cedar::Matchers::Stringifiers::string_for_method_invocation(this->selector(), arguments);
        return [NSString stringWithFormat:@"have received message [%@]", methodSignatureString];
    }
    /*virtual*/ NSString * HaveReceived::failure_message_end(id<CedarDouble> cedarDouble) const {
        NSMutableString *message = [this->failure_message_end() mutableCopy];
        if ([cedarDouble sent_messages].count) {
            [message appendString:@", but received:\n"];
            for (NSInvocation *invocation in [cedarDouble sent_messages]) {
                [message appendFormat:@" [%@]\n", Cedar::Matchers::Stringifiers::string_for_method_invocation(invocation)];
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
