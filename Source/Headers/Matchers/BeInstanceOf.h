#import "Base.h"

namespace Cedar { namespace Matchers {
    class BeInstanceOf : public Base {
    private:
        BeInstanceOf & operator=(const BeInstanceOf &);

    public:
        explicit BeInstanceOf(const Class expectedValue);
        ~BeInstanceOf();
        // Allow default copy ctor.

        template<typename U>
        bool matches(const U &) const;

        BeInstanceOf & or_any_subclass();

    protected:
        virtual NSString * failure_message_end() const;

    private:
        const Class expectedClass_;
        bool includeSubclasses_;
    };

    BeInstanceOf be_instance_of(const Class);

#pragma mark Generic
    template<typename U>
    bool BeInstanceOf::matches(const U & actualValue) const {
        this->build_failure_message_start([NSString stringWithFormat:@"%@ (%@)", actualValue, [actualValue class]]);

        if (includeSubclasses_) {
            return [actualValue isKindOfClass:expectedClass_];
        } else {
            return [actualValue isMemberOfClass:expectedClass_];
        }
    }
}}
