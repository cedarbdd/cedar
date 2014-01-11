#import <Foundation/Foundation.h>
#import "Base.h"

namespace Cedar { namespace Matchers {
    class BeFalsy : public Base<> {
    private:
        BeFalsy & operator=(const BeFalsy &);

    public:
        inline BeFalsy() : Base<>() {}
        inline ~BeFalsy() {}
        // Allow default copy ctor.

        inline const BeFalsy & operator()() const { return *this; }

        template<typename U>
        bool matches(const U &) const;

    protected:
        inline /*virtual*/ NSString * failure_message_end() const { return @"evaluate to false"; }
    };

    static const BeFalsy be_falsy = BeFalsy();

#pragma mark Generic
    template<typename U>
    bool BeFalsy::matches(const U & actualValue) const {
        return !actualValue;
    }

}}
