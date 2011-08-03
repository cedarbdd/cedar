#import <Foundation/Foundation.h>
#import "Base.h"

namespace Cedar { namespace Matchers {
    class BeTruthy : public Base {
    private:
        BeTruthy & operator=(const BeTruthy &);

    public:
        BeTruthy();
        ~BeTruthy();
        // Allow default copy ctor.

        virtual NSString * failure_message_end() const;

        template<typename U>
        bool matches(const U &) const;
    };

    BeTruthy be_truthy();

#pragma mark Generic
    template<typename U>
    bool BeTruthy::matches(const U & actualValue) const {
        this->build_failure_message_start(actualValue);
        return !!actualValue;
    }

}}
