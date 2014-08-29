#import <Foundation/Foundation.h>
#import "Base.h"
#import "CDRSpecFailure.h"

#include <stdexcept>

#pragma mark - private interface
namespace Cedar { namespace Matchers { namespace Private {
    struct BeNilMessageBuilder {
        template<typename U>
        static NSString * string_for_actual_value(const U & value) {
            // ARC bug: http://lists.apple.com/archives/objc-language/2012/Feb/msg00078.html
            // Also blocks aren't considered a pointer type under both ARC and MRC
            if (strcmp(@encode(U), @encode(id)) == 0 || strcmp(@encode(U), @encode(void(^)(void))) == 0) {
                void *ptrOfPtr = (void *)&value;
                void *ptr = *(reinterpret_cast<void **>(ptrOfPtr));
                return ptr ? [NSString stringWithFormat:@"%p", ptr] : @"nil";
            }

            throw std::logic_error("Should never generate a failure message for a nil comparison to non-pointer type.");
        }

        template<typename U>
        static NSString * string_for_actual_value(U * const & value) {
            return value ? [NSString stringWithFormat:@"%p", value] : @"nil";
        }
    };

    class BeNil : public Base<BeNilMessageBuilder> {
    private:
        BeNil & operator=(const BeNil &);

    public:
        inline BeNil() : Base<BeNilMessageBuilder>() {}
        inline ~BeNil() {}
        // Allow default copy ctor.

        inline const BeNil & operator()() const { return *this; }

        template<typename U>
        bool matches(const U &) const;

        template<typename U>
        bool matches(U * const &) const;

    protected:
        inline /*virtual*/ NSString * failure_message_end() const { return @"be nil"; }
    };

    static const BeNil be_nil = BeNil();

#pragma mark Generic
    template<typename U>
    bool BeNil::matches(const U & actualValue) const {
        // ARC bug: http://lists.apple.com/archives/objc-language/2012/Feb/msg00078.html
        // Also blocks aren't considered a pointer type under both ARC and MRC
        if (strcmp(@encode(U), @encode(id)) == 0 || strcmp(@encode(U), @encode(void(^)(void))) == 0) {
            void *ptrOfPtr = (void *)&actualValue;
            void *ptr = *(reinterpret_cast<void **>(ptrOfPtr));
            return !ptr;
        }

        [[CDRSpecFailure specFailureWithReason:@"Attempt to compare non-pointer type to nil"] raise];
        return NO;
    }

    template<typename U>
    bool BeNil::matches(U * const & actualValue) const {
        return !actualValue;
    }
}}}

#pragma mark - public interface
namespace Cedar { namespace Matchers {
    using CedarBeNil = Cedar::Matchers::Private::BeNil;

    static const CedarBeNil be_nil = CedarBeNil();
}}
