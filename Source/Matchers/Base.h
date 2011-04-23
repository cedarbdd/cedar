#import <Foundation/Foundation.h>
#import <sstream>

namespace Cedar { namespace Matchers {

    /**
     * Basic functionality for all matchers.  Meant to be mixed into concrete
     * matcher classes.
     */
    class Base {
    private:
        Base & operator=(const Base &);

    public:
        Base();
        virtual ~Base() = 0;
        // Allow default copy ctor.

        template<typename U>
        NSString * string_for(const U &) const;
        NSString * string_for(const char value) const;
        NSString * string_for(const BOOL value) const;
        NSString * string_for(const id value) const;
        NSString * string_for(NSObject * const) const;
        NSString * string_for(NSString * const) const;

        template<typename U>
        void build_failure_message_start(const U &) const;
        NSString * failure_message_start() const;

    private:
        mutable NSString *valueString_;
    };

    template<typename U>
    NSString * Base::string_for(const U & value) const {
        std::stringstream temp;
        temp << value;
        return [NSString stringWithCString:temp.str().c_str() encoding:NSUTF8StringEncoding];
    }

    template<typename U>
    void Base::build_failure_message_start(const U & value) const {
        valueString_ = [this->string_for(value) retain];
    }

}}
