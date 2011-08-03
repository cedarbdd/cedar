#import <Foundation/Foundation.h>
#import <sstream>

namespace Cedar { namespace Matchers {

    namespace StringConversions {
        template<typename U>
        NSString * string_for(const U & value) {
            std::stringstream temp;
            temp << value;
            return [NSString stringWithCString:temp.str().c_str() encoding:NSUTF8StringEncoding];
        }

        NSString * string_for(const char value);
        NSString * string_for(const BOOL value);
        NSString * string_for(const id value);
        NSString * string_for(NSObject * const);
        NSString * string_for(NSString * const);
        NSString * string_for(NSNumber * const);
    }

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
        failureMessageStart_ = [StringConversions::string_for(value) retain];
    }

}}
