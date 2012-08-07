#import <Foundation/Foundation.h>
#import <tr1/memory>
#import <vector>
#import "InvocationMatcher.h"
#import "Argument.h"
#import "ReturnValue.h"

namespace Cedar { namespace Doubles {

    class StubbedMethod : private InvocationMatcher {
    private:
        StubbedMethod & operator=(const StubbedMethod &);

    public:
        StubbedMethod(SEL);
        StubbedMethod(const char *);

        template<typename T>
        StubbedMethod & and_return(const T &);

        StubbedMethod & with(const Argument::shared_ptr_t argument);
        StubbedMethod & and_with(const Argument::shared_ptr_t argument);

        template<typename T>
        StubbedMethod & with(const T &);
        template<typename T>
        StubbedMethod & and_with(const T &);

        StubbedMethod & and_raise_exception();
        StubbedMethod & and_raise_exception(NSObject * exception);

        bool has_return_value() const { return return_value_argument_.get(); };
        Argument & return_value() const { return *return_value_argument_; };

        struct SelCompare {
            bool operator() (const SEL& lhs, const SEL& rhs) const {
                return strcmp(sel_getName(lhs), sel_getName(rhs)) < 0;
            }
        };
        typedef std::tr1::shared_ptr<StubbedMethod> shared_ptr_t;
        typedef std::map<SEL, shared_ptr_t, SelCompare> selector_map_t;

        const SEL selector() const;
        bool matches(NSInvocation * const invocation) const;
        bool invoke(const NSInvocation * const invocation) const;
        void validate_against_instance(id instance) const;

    private:
        Argument::shared_ptr_t return_value_argument_;
        NSObject * exception_to_raise_;
    };

    inline StubbedMethod::StubbedMethod(SEL selector) :
        InvocationMatcher(selector),
        exception_to_raise_(0) {
    }

    inline StubbedMethod::StubbedMethod(const char * method_name) :
        InvocationMatcher(sel_registerName(method_name)),
        exception_to_raise_(0) {
    }

    template<typename T>
    StubbedMethod & StubbedMethod::and_return(const T & return_value) {
        return_value_argument_ = Argument::shared_ptr_t(new ReturnValue<T>(return_value));
        return *this;
    }

    inline StubbedMethod & StubbedMethod::with(const Argument::shared_ptr_t argument) {
        this->add_argument(argument);
        return *this;
    };

    inline StubbedMethod & StubbedMethod::and_with(const Argument::shared_ptr_t argument) {
        return with(argument);
    }

    template<typename T>
    StubbedMethod & StubbedMethod::with(const T & argument) {
        return with(Argument::shared_ptr_t(new TypedArgument<T>(argument)));
    }

    template<typename T>
    StubbedMethod & StubbedMethod::and_with(const T & argument) {
        return with(argument);
    }

    inline StubbedMethod & StubbedMethod::and_raise_exception() {
        return and_raise_exception([NSException exceptionWithName:NSInternalInconsistencyException reason:@"Invoked a stub with exceptional behavior" userInfo:nil]);
    }

    inline StubbedMethod & StubbedMethod::and_raise_exception(NSObject * exception) {
        exception_to_raise_ = exception;
        return *this;
    }

    inline void StubbedMethod::validate_against_instance(id instance) const {
        verify_count_and_types_of_arguments(instance);

        if (has_return_value()) {
            const char * const methodReturnType = [[instance methodSignatureForSelector:selector()] methodReturnType];
            if (!return_value().matches_encoding(methodReturnType)) {
                NSString * selectorString = NSStringFromSelector(selector());
                [[NSException exceptionWithName:NSInternalInconsistencyException
                                         reason:[NSString stringWithFormat:@"Invalid return value type (%s) for %@", return_value().value_encoding(), selectorString]
                                       userInfo:nil] raise];

            }
        }
    }

    inline const SEL StubbedMethod::selector() const {
        return InvocationMatcher::selector();
    }

    inline bool StubbedMethod::matches(NSInvocation * const invocation) const {
        return InvocationMatcher::matches(invocation);
    }

    inline bool StubbedMethod::invoke(const NSInvocation * const invocation) const {
        if (exception_to_raise_) {
            @throw exception_to_raise_;
        } else if (this->has_return_value()) {
            const void * returnValue = return_value().value_bytes();
            [invocation setReturnValue:const_cast<void *>(returnValue)];
            return true;
        }
        return false;
    }

}}
