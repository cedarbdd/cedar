#import <Foundation/Foundation.h>
#import <sstream>

#import "CedarStringifiers.h"
#ifdef CEDAR_CUSTOM_STRINGIFIERS
#import CEDAR_CUSTOM_STRINGIFIERS
#endif

namespace Cedar { namespace Matchers {
    /**
     * Basic functionality for all matchers.  Meant to be used as a convenience base class for
     * matcher classes.
     */
    class Base {
    private:
        Base & operator=(const Base &);

    public:
        Base();
        virtual ~Base() = 0;
        // Allow default copy ctor.

        NSString * failure_message() const;
        NSString * negative_failure_message() const;

    protected:
        template<typename U>
        void build_failure_message_start(const U &) const;

        virtual NSString * failure_message_end() const = 0;

    private:
        mutable NSString *failureMessageStart_;
    };

    template<typename U>
    void Base::build_failure_message_start(const U & value) const {
        [failureMessageStart_ autorelease];
        failureMessageStart_ = [Stringifiers::string_for(value) retain];
    }
}}
