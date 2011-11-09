#import <Foundation/Foundation.h>
#import "Base.h"
#import "CDRSpecFailure.h"

namespace Cedar { namespace Matchers {
    class BeNil : public Base {
    private:
        BeNil & operator=(const BeNil &);

    public:
        inline BeNil() : Base() {}
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
        [[CDRSpecFailure specFailureWithReason:@"Attempt to compare non-pointer type to nil"] raise];
        return NO;
    }

    template<typename U>
    bool BeNil::matches(U * const &actualValue) const {
        this->build_failure_message_start([NSString stringWithFormat:@"%x", actualValue]);
        return !actualValue;
    }

}}
