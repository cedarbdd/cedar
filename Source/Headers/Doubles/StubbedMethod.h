#import <Foundation/Foundation.h>
#import <tr1/memory>
#import <vector>
#import "Argument.h"
#import "InvocationMatcher.h"

namespace Cedar { namespace Doubles {

    class StubbedMethod : private InvocationMatcher {
    private:
        StubbedMethod(const StubbedMethod & );
        StubbedMethod & operator=(const StubbedMethod &);

    public:
        StubbedMethod(SEL, id);

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
        typedef std::tr1::shared_ptr<StubbedMethod> ptr_t;
        typedef std::map<SEL, ptr_t, SelCompare> selector_map_t;

        bool matches(NSInvocation * const invocation) const;
        bool invoke(const NSInvocation * const invocation) const;

    private:
        NSMethodSignature *method_signature();

    private:
        id parent_;
        std::auto_ptr<Argument> return_value_argument_;
        NSObject * exception_to_raise_;
    };

    inline StubbedMethod::StubbedMethod(SEL selector, id parent) :
        InvocationMatcher(selector),
        parent_(parent),
        return_value_argument_(0),
        exception_to_raise_(0) {
    }

    template<typename T>
    StubbedMethod & StubbedMethod::and_return(const T & return_value) {
        if (strcmp([this->method_signature() methodReturnType], @encode(T))) {
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"Invalid return value type (%s) for %s", @encode(T), this->selector()]
                                   userInfo:nil] raise];
        }
        return_value_argument_ = std::auto_ptr<Argument>(new TypedArgument<T>(return_value));
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

    inline bool StubbedMethod::matches(NSInvocation * const invocation) const {
        this->verify_correct_number_of_arguments(parent_);
        return this->matches_invocation(invocation);
    }

    inline bool StubbedMethod::invoke(const NSInvocation * const invocation) const {
        const void * returnValue;

        if (exception_to_raise_) {
            @throw exception_to_raise_;

        } else if (has_return_value()) {
            returnValue = return_value().value_bytes();
            [invocation setReturnValue:const_cast<void *>(returnValue)];
        }
    }

#pragma mark - Private interface
    inline NSMethodSignature *StubbedMethod::method_signature() {
        return [parent_ methodSignatureForSelector:this->selector()];
    }

}}
