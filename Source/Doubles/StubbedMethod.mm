#import "StubbedMethod.h"
#import "AnyArgument.h"

namespace Cedar { namespace Doubles {

    StubbedMethod::StubbedMethod(SEL selector) : InvocationMatcher(selector), exception_to_raise_(0), invocation_block_(0) {}
    StubbedMethod::StubbedMethod(const char * method_name) : InvocationMatcher(sel_registerName(method_name)), exception_to_raise_(0), invocation_block_(0) {}
    StubbedMethod::StubbedMethod(const StubbedMethod &rhs)
    : InvocationMatcher(rhs)
    , return_value_argument_(rhs.return_value_argument_)
    , invocation_block_([rhs.invocation_block_ retain])
    , exception_to_raise_(rhs.exception_to_raise_) {}

    /*virtual*/ StubbedMethod::~StubbedMethod() {
        [invocation_block_ release];
    }

    StubbedMethod & StubbedMethod::and_do(invocation_block_t block) {
        if (this->has_return_value()) {
            NSString * selectorString = NSStringFromSelector(this->selector());
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"Multiple return values specified for <%@>", selectorString]
                                   userInfo:nil] raise];
        }

        invocation_block_ = [block copy];
        return *this;
    }

    StubbedMethod & StubbedMethod::with(const Argument::shared_ptr_t argument) {
        this->add_argument(argument);
        return *this;
    };

    StubbedMethod & StubbedMethod::and_with(const Argument::shared_ptr_t argument) {
        return with(argument);
    }

    StubbedMethod & StubbedMethod::and_raise_exception() {
        return and_raise_exception([NSException exceptionWithName:NSInternalInconsistencyException reason:@"Invoked a stub with exceptional behavior" userInfo:nil]);
    }

    StubbedMethod & StubbedMethod::and_raise_exception(NSObject * exception) {
        exception_to_raise_ = exception;
        return *this;
    }

    bool StubbedMethod::matches_arguments(const StubbedMethod &other_stubbed_method) const {
        Cedar::Doubles::InvocationMatcher::arguments_vector_t arguments = this->arguments();
        Cedar::Doubles::InvocationMatcher::arguments_vector_t other_arguments = other_stubbed_method.arguments();

        Cedar::Doubles::InvocationMatcher::arguments_vector_t::iterator argument_it;
        Cedar::Doubles::InvocationMatcher::arguments_vector_t::iterator other_argument_it;
        for (argument_it = arguments.begin(), other_argument_it = other_arguments.begin(); argument_it != arguments.end(); ++argument_it, ++other_argument_it) {
            Cedar::Doubles::Argument::shared_ptr_t argument_ptr = *argument_it;
            Cedar::Doubles::Argument::shared_ptr_t other_argument_ptr = *other_argument_it;

            if ((*argument_ptr) != (*other_argument_ptr)) {
                return false;
            }
        }
        return true;
    }

    bool StubbedMethod::contains_anything_argument() const {
        Cedar::Doubles::InvocationMatcher::arguments_vector_t arguments = this->arguments();

        Cedar::Doubles::InvocationMatcher::arguments_vector_t::iterator argument_it;
        for (argument_it = arguments.begin(); argument_it != arguments.end(); ++argument_it) {
            Cedar::Doubles::Argument::shared_ptr_t argument_ptr = *argument_it;

            if (strcmp(typeid(*argument_ptr).name(), typeid(*Arguments::anything).name()) == 0) {
                return true;
            }
        }
        return false;
    }

    void StubbedMethod::validate_against_instance(id instance) const {
        this->verify_count_and_types_of_arguments(instance);

        if (this->has_return_value()) {
            const char * const methodReturnType = [[instance methodSignatureForSelector:this->selector()] methodReturnType];
            if (!this->return_value().matches_encoding(methodReturnType)) {
                NSString * selectorString = NSStringFromSelector(this->selector());
                [[NSException exceptionWithName:NSInternalInconsistencyException
                                         reason:[NSString stringWithFormat:@"Invalid return value type (%s) for %@", this->return_value().value_encoding(), selectorString]
                                       userInfo:nil] raise];

            }
        }
    }

    NSString * StubbedMethod::arguments_string() const {
        NSMutableString *argumentsString = [NSMutableString stringWithString:@"("];
        Cedar::Doubles::InvocationMatcher::arguments_vector_t arguments = this->arguments();
        Cedar::Doubles::InvocationMatcher::arguments_vector_t::iterator argument_it;
        for (argument_it = arguments.begin(); argument_it != arguments.end(); ++argument_it) {
            [argumentsString appendFormat:@"<%@>", (*argument_it)->value_string()];
        }
        return [argumentsString stringByAppendingString:@")"];
    }

    const SEL StubbedMethod::selector() const {
        return InvocationMatcher::selector();
    }

    bool StubbedMethod::matches(NSInvocation * const invocation) const {
        return InvocationMatcher::matches(invocation);
    }

    bool StubbedMethod::invoke(NSInvocation * invocation) const {
        if (exception_to_raise_) {
            @throw exception_to_raise_;
        } else if (this->has_invocation_block()) {
            invocation_block_(invocation);
        } else if (this->has_return_value()) {
            const void * returnValue = this->return_value().value_bytes();
            [invocation setReturnValue:const_cast<void *>(returnValue)];
            return true;
        }
        return false;
    }

}}
