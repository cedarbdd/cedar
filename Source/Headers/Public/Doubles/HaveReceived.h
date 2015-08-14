#import "Base.h"
#import "InvocationMatcher.h"
#import "CedarDouble.h"

namespace Cedar { namespace Doubles {

    extern "C" Class object_getClass(id);
    extern NSString * recorded_invocations_message(NSArray *recordedInvocations);

    template<typename MessageBuilder_ = Matchers::BaseMessageBuilder>
    class HaveReceived : private InvocationMatcher {
    private:
        HaveReceived & operator=(const HaveReceived &);

    public:
        explicit HaveReceived(const SEL);
        ~HaveReceived();
        // Allow default copy ctor.

        template<typename U>
        NSString * failure_message_for(const U &) const;
        template<typename U>
        NSString * negative_failure_message_for(const U &) const;

        template<typename T>
        HaveReceived & with(const T &);
        template<typename T, typename... ArgumentPack>
        HaveReceived & with(const T &, ArgumentPack... pack);
        template<typename T>
        HaveReceived & and_with(const T & argument) { return with(argument); }

        bool matches(id) const;

    protected:
        template<typename U>
        NSString * failure_message_end(const U & value, bool negation) const;

    private:
        void verify_object_is_a_double(id instance) const {
            Class clazz = object_getClass(instance);
            if (![clazz instancesRespondToSelector:@selector(sent_messages)]) {
                [[NSException exceptionWithName:NSInternalInconsistencyException
                                         reason:[NSString stringWithFormat:@"Received expectation for non-double object <%@>", instance]
                                       userInfo:nil]
                 raise];
            }
        }
    };

    inline HaveReceived<> have_received(const SEL expectedSelector) {
        return HaveReceived<>(expectedSelector);
    }

    inline HaveReceived<> have_received(const char * expectedMethod) {
        return HaveReceived<>(NSSelectorFromString([NSString stringWithUTF8String:expectedMethod]));
    }

    template<>
    template<typename T>
    HaveReceived<> & HaveReceived<>::with(const T & value) {
        this->add_argument(value);
        return *this;
    }

    template<typename U>
    template<typename T, typename... ArgumentPack>
    HaveReceived<U> & HaveReceived<U>::with(const T & value, ArgumentPack... pack) {
        this->with(value);
        this->with(pack...);
        return *this;
    }

#pragma mark - Needs organization

    template<typename MessageBuilder_>
    HaveReceived<MessageBuilder_>::HaveReceived(const SEL expectedSelector)
    : InvocationMatcher(expectedSelector) {
    }

    template<typename MessageBuilder_>
    HaveReceived<MessageBuilder_>::~HaveReceived() {
    }

    template<typename MessageBuilder_>
    bool HaveReceived<MessageBuilder_>::matches(id instance) const {
        this->verify_object_is_a_double(instance);
        this->verify_count_and_types_of_arguments(instance);

        for (NSInvocation *invocation in [instance sent_messages]) {
            if (this->InvocationMatcher::matches(invocation)) {
                return true;
            }
        }
        return false;
    }

    template<typename MessageBuilder_>
    template<typename U>
    NSString * HaveReceived<MessageBuilder_>::failure_message_for(const U & value) const {
        NSString * failureMessageEnd = this->failure_message_end(value, false);
        NSString * actualValueString = MessageBuilder_::string_for_actual_value(value);
        return [NSString stringWithFormat:@"Expected <%@> to %@", actualValueString, failureMessageEnd];
    }

    template<typename MessageBuilder_>
    template<typename U>
    NSString * HaveReceived<MessageBuilder_>::negative_failure_message_for(const U & value) const {
        NSString * failureMessageEnd = this->failure_message_end(value, true);
        NSString * actualValueString = MessageBuilder_::string_for_actual_value(value);
        return [NSString stringWithFormat:@"Expected <%@> to not %@", actualValueString, failureMessageEnd];
    }

#pragma mark - Protected interface
    template<typename MessageBuilder_>
    template<typename U>
    NSString * HaveReceived<MessageBuilder_>::failure_message_end(const U & value, bool negation) const {
        NSString * selectorString = NSStringFromSelector(this->selector());
        NSMutableString *message = [NSMutableString stringWithFormat:@"have received message <%@>", selectorString];
        if (this->arguments().size()) {
            [message appendString:@", with arguments: <"];
            arguments_vector_t::const_iterator cit = this->arguments().begin();
            [message appendString:(*cit++)->value_string()];
            for (; cit != this->arguments().end(); ++cit) {
                [message appendString:[NSString stringWithFormat:@", %@", (*cit)->value_string()]];
            }
            [message appendString:@">"];

            NSArray *recordedInvocations = [(id<CedarDouble>)value sent_messages];
            if (recordedInvocations.count > 0 && !negation) {
                [message appendString:@" but received messages:\n"];
                [message appendString:recorded_invocations_message(recordedInvocations)];
            }
        }
        return message;
    }

}}
