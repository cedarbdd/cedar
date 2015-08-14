#import <Foundation/Foundation.h>
#import <memory>
#import <vector>
#import "InvocationMatcher.h"
#import "Argument.h"
#import "ReturnValue.h"

namespace Cedar { namespace Doubles {

    class StubbedMethod : private InvocationMatcher {
    private:
        typedef void (^invocation_block_t)(NSInvocation *);
        typedef id implementation_block_t;

    private:
        StubbedMethod & operator=(const StubbedMethod &);

    public:
        StubbedMethod(SEL);
        StubbedMethod(const char *);
        StubbedMethod(const StubbedMethod &);
        virtual ~StubbedMethod();

        template<typename T>
        StubbedMethod & and_return(const T &);
        StubbedMethod & and_do_block(implementation_block_t block);
        StubbedMethod & and_do(invocation_block_t);

        StubbedMethod & with(const Argument::shared_ptr_t argument);
        StubbedMethod & and_with(const Argument::shared_ptr_t argument);
        StubbedMethod & again();

        template<typename T, typename... ArgumentPack>
        StubbedMethod & with(const T &, ArgumentPack... pack);

        template<typename T>
        StubbedMethod & with(const T &);
        template<typename T>
        StubbedMethod & and_with(const T &);
        inline StubbedMethod & with(const char *argument);

        StubbedMethod & and_raise_exception();
        StubbedMethod & and_raise_exception(NSObject * exception);

        ReturnValue & return_value() const { return *return_value_; };
        bool is_override() const { return is_override_; };

        struct SelCompare {
            bool operator() (const SEL& lhs, const SEL& rhs) const {
                return strcmp(sel_getName(lhs), sel_getName(rhs)) < 0;
            }
        };
        typedef std::shared_ptr<StubbedMethod> shared_ptr_t;
        typedef std::vector<shared_ptr_t> stubbed_method_vector_t;
        typedef std::map<SEL, stubbed_method_vector_t, SelCompare> selector_map_t;

        const SEL selector() const;
        bool matches_arguments(const StubbedMethod &) const;
        bool arguments_equal(const StubbedMethod &) const;
        bool matches(NSInvocation * const invocation) const;
        bool invoke(NSInvocation * invocation) const;
        void validate_against_instance(id instance) const;
        NSString *arguments_string() const;
        unsigned int arguments_specificity_ranking() const;

    private:
        bool has_return_value() const { return return_value_.get(); };
        bool has_invocation_block() const { return invocation_block_; }
        bool has_implementation_block() const { return implementation_block_; }

        void verify_return_value_type(id instance) const;
        void verify_implementation_block_return_type(id instance) const;
        void verify_implementation_block_arguments(id instance) const;

        void raise_for_multiple_return_values() const;
        void raise_for_multiple_blocks() const;
    private:
        ReturnValue::shared_ptr_t return_value_;
        bool is_override_;
        invocation_block_t invocation_block_;
        implementation_block_t implementation_block_;
        NSObject * exception_to_raise_;
    };

    template<typename T>
    StubbedMethod & StubbedMethod::and_return(const T & return_value) {
        if (this->has_invocation_block()) {
            this->raise_for_multiple_return_values();
        } else if (this->has_implementation_block()) {
            this->raise_for_multiple_return_values();
        }

        return_value_ = ReturnValue::shared_ptr_t(new TypedReturnValue<T>(return_value));
        return *this;
    }

    template<typename T>
    StubbedMethod & StubbedMethod::with(const T & argument) {
        return with(Argument::shared_ptr_t(new ValueArgument<T>(argument)));
    }

    StubbedMethod & StubbedMethod::with(const char *argument) {
        return with(Argument::shared_ptr_t(new CharValueArgument(argument)));
    }

    template<typename T>
    StubbedMethod & StubbedMethod::and_with(const T & argument) {
        return with(argument);
    }

    template<typename T, typename... ArgumentPack>
    StubbedMethod & StubbedMethod::with(const T & value, ArgumentPack... pack) {
        this->with(value);
        this->with(pack...);
        return *this;
    }
}}
