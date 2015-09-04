#import "Base.h"

#pragma mark - private interface
namespace Cedar { namespace Matchers { namespace Private {
    struct BeInstanceOfMessageBuilder {
        template<typename U>
        static NSString * string_for_actual_value(const U & value) {
            id idValue = value;
            return [NSString stringWithFormat:@"%@ (%@)", idValue, NSStringFromClass([idValue class])];
        }
    };

    class BeInstanceOf : public Base<BeInstanceOfMessageBuilder> {
    private:
        BeInstanceOf & operator=(const BeInstanceOf &);

    public:
        explicit BeInstanceOf(const Class expectedValue);
        ~BeInstanceOf();
        // Allow default copy ctor.

        template<typename U>
        bool matches(const U &) const;

        BeInstanceOf & or_any_subclass();

        template<typename U>
        NSString * failure_message_for(const U &) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        const Class expectedClass_;
        bool includeSubclasses_;
    };

    inline BeInstanceOf::BeInstanceOf(const Class expectedClass)
    : Base<BeInstanceOfMessageBuilder>(), expectedClass_(expectedClass), includeSubclasses_(false) {}

    inline BeInstanceOf::~BeInstanceOf() {}

    inline BeInstanceOf & BeInstanceOf::or_any_subclass() {
        includeSubclasses_ = true;
        return *this;
    }

    template<typename U>
    NSString * BeInstanceOf::failure_message_for(const U & value) const {
        NSString *failureMessage = Base<BeInstanceOfMessageBuilder>::failure_message_for(value);

        if ([NSStringFromClass(expectedClass_) isEqualToString:NSStringFromClass([value class])]) {
            failureMessage = [failureMessage stringByAppendingFormat:@". %@", @"Did you accidentally add the class to your specs target also?"];
        }

        return failureMessage;
    }

    inline /*virtual*/ NSString * BeInstanceOf::failure_message_end() const {
        NSMutableString *messageEnd = [NSMutableString stringWithFormat:@"be an instance of class <%@>", expectedClass_];
        if (includeSubclasses_) {
            [messageEnd appendString:@", or any of its subclasses"];
        }
        return messageEnd;
    }

#pragma mark Generic
    template<typename U>
    bool BeInstanceOf::matches(const U & actualValue) const {
        if (includeSubclasses_) {
            return [actualValue isKindOfClass:expectedClass_];
        } else {
            return [actualValue isMemberOfClass:expectedClass_];
        }
    }
}}}

#pragma mark - public interface
namespace Cedar { namespace Matchers {
    using CedarBeInstanceOf = Cedar::Matchers::Private::BeInstanceOf;

    inline CedarBeInstanceOf be_instance_of(const Class expectedValue) {
        return CedarBeInstanceOf(expectedValue);
    }
}}
