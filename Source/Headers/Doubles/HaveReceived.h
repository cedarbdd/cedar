#import "Base.h"
#import "Argument.h"
#import "objc/runtime.h"
#import "InvocationMatcher.h"

namespace Cedar { namespace Doubles {

    class HaveReceived : public Matchers::Base<>, private InvocationMatcher {
    private:
        HaveReceived & operator=(const HaveReceived &);

    public:
        explicit HaveReceived(const SEL);
        ~HaveReceived();
        // Allow default copy ctor.

        template<typename T>
        HaveReceived & with(const T &);
        template<typename T>
        HaveReceived & and_with(const T & argument) { return with(argument); }

        bool matches(id) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        void verify_object_is_a_double(id) const;
    };

    HaveReceived have_received(const SEL expectedSelector);
    HaveReceived have_received(const char * expectedMethod);

    template<typename T>
    HaveReceived & HaveReceived::with(const T & value) {
        this->add_argument(value);
        return *this;
    }

    // This belongs in a separate implementation file, but doing so generates an
    // inscrutable linker error:
    //
    // ld: bad codegen, pointer diff in ___block_global_9 to global weak symbol
    // __ZTVN5Cedar8Matchers4BaseINS0_18BaseMessageBuilderEEE for architecture i386
#pragma mark Implementation

    inline HaveReceived have_received(const SEL expectedSelector) {
        return HaveReceived(expectedSelector);
    }

    inline HaveReceived have_received(const char * expectedMethod) {
        return HaveReceived(NSSelectorFromString([NSString stringWithUTF8String:expectedMethod]));
    }

    inline HaveReceived::HaveReceived(const SEL expectedSelector)
        : Base<>(), InvocationMatcher(expectedSelector) {
    }

    inline HaveReceived::~HaveReceived() {
    }

    inline bool HaveReceived::matches(id instance) const {
        this->verify_object_is_a_double(instance);
        this->verify_count_and_types_of_arguments(instance);

        for (NSInvocation *invocation in [instance sent_messages]) {
            if (InvocationMatcher::matches(invocation)) {
                return true;
            }
        }
        return false;
    }

    inline void HaveReceived::verify_object_is_a_double(id instance) const {
        if (![[instance class] conformsToProtocol:@protocol(CedarDouble)]) {
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"Received expectation for non-double object <%@>", instance]
                                   userInfo:nil]
             raise];
        }
    }

#pragma mark Protected interface
    inline /*virtual*/ NSString * HaveReceived::failure_message_end() const {
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
        }
        return message;
    }

}}
