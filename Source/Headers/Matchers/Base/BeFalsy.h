#import <Foundation/Foundation.h>
#import "Base.h"

#pragma mark - private interface
namespace Cedar { namespace Matchers { namespace Private {
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

}}}

#pragma mark - public interface
namespace Cedar { namespace Matchers {
    using CedarBeFalsy = Cedar::Matchers::Private::BeFalsy;
    static const CedarBeFalsy be_falsy = CedarBeFalsy();
}}
