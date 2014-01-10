#import <Foundation/Foundation.h>
#import <sstream>

#import "CedarDouble.h"
#import "CedarStringifiers.h"
#import "CDRSpyInfo.h"

namespace Cedar { namespace Matchers {
    struct BaseMessageBuilder {
        template<typename U>
        static NSString * string_for_actual_value(const U & value) {
            return Stringifiers::string_for(value);
        }
    };

    /**
     * Basic functionality for all matchers.  Meant to be used as a convenience base class for
     * matcher classes.
     */
    template<typename MessageBuilder_ = BaseMessageBuilder>
    class Base {
    private:
        Base & operator=(const Base &);
        bool isCedarDouble(id obj) const;

        template<typename U>
        NSString * _failure_message_end(const U &) const;

    public:
        Base();
        virtual ~Base() = 0;
        // Allow default copy ctor.

        template<typename U>
        NSString * failure_message_for(const U &) const;
        template<typename U>
        NSString * negative_failure_message_for(const U &) const;

    protected:
        virtual NSString * failure_message_end() const = 0;
        virtual NSString * failure_message_end(const id<CedarDouble> cedarDouble) const {
            return this->failure_message_end();
        };
    };

    template<typename MessageBuilder_>
    Base<MessageBuilder_>::Base() {}
    template<typename MessageBuilder_>
    Base<MessageBuilder_>::~Base() {}

    template<typename MessageBuilder_> template<typename U>
    NSString * Base<MessageBuilder_>::_failure_message_end(const U & value) const {
        // ARC bug: http://lists.apple.com/archives/objc-language/2012/Feb/msg00078.html
        if (strcmp(@encode(U), @encode(id)) == 0) {
            void *ptrOfPtr = (void *)&value;
            void *ptr = *(reinterpret_cast<void **>(ptrOfPtr));
#if __has_feature(objc_arc)
            id obj = (__bridge id)ptr;
#else
            id obj = (id)ptr;
#endif
            if (Cedar::Doubles::isCedarDouble(obj)) {
                return this->failure_message_end((id<CedarDouble>)obj);
            }
        }
        return this->failure_message_end();
    }

    template<typename MessageBuilder_> template<typename U>
    NSString * Base<MessageBuilder_>::failure_message_for(const U & value) const {
        NSString * failureMessageEnd = this->_failure_message_end(value);
        NSString * actualValueString = MessageBuilder_::string_for_actual_value(value);
        return [NSString stringWithFormat:@"Expected <%@> to %@", actualValueString, failureMessageEnd];
    }

    template<typename MessageBuilder_> template<typename U>
    NSString * Base<MessageBuilder_>::negative_failure_message_for(const U & value) const {
        NSString * failureMessageEnd = this->_failure_message_end(value);
        NSString * actualValueString = MessageBuilder_::string_for_actual_value(value);
        return [NSString stringWithFormat:@"Expected <%@> to not %@", actualValueString, failureMessageEnd];
    }
}}
