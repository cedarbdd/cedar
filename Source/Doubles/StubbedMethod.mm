#import "StubbedMethod.h"
#import "AnyArgument.h"
#import "CDRTypeUtilities.h"
#import "NSInvocation+Cedar.h"
#import "NSMethodSignature+Cedar.h"
#import <objc/runtime.h>
#import <numeric>

namespace Cedar { namespace Doubles {

    StubbedMethod::StubbedMethod(SEL selector) : InvocationMatcher(selector), exception_to_raise_(0), invocation_block_(0), implementation_block_(0), is_override_(false) {}
    StubbedMethod::StubbedMethod(const char * method_name) : InvocationMatcher(sel_registerName(method_name)), exception_to_raise_(0), invocation_block_(0), implementation_block_(0), is_override_(false) {}
    StubbedMethod::StubbedMethod(const StubbedMethod &rhs)
    : InvocationMatcher(rhs)
    , return_value_(rhs.return_value_)
    , invocation_block_([rhs.invocation_block_ retain])
    , implementation_block_([rhs.implementation_block_ retain])
    , exception_to_raise_(rhs.exception_to_raise_)
    , is_override_(rhs.is_override_) {}

    /*virtual*/ StubbedMethod::~StubbedMethod() {
        [invocation_block_ release];
        [implementation_block_ release];
    }

    StubbedMethod & StubbedMethod::and_do(invocation_block_t block) {
        if (this->has_return_value()) {
            this->raise_for_multiple_return_values();
        } else if (this->has_implementation_block()) {
            this->raise_for_multiple_blocks();
        }

        invocation_block_ = [block copy];
        return *this;
    }

    StubbedMethod & StubbedMethod::and_do_block(implementation_block_t block) {
        if (![block isKindOfClass:NSClassFromString(@"NSBlock")]) {
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"Attempted to stub and do a block that isn't a block for <%@>", NSStringFromSelector(this->selector())]
                                   userInfo:nil] raise];
        }

        if (this->has_return_value()) {
            this->raise_for_multiple_return_values();
        } else if (this->has_invocation_block()) {
            this->raise_for_multiple_blocks();
        }

        implementation_block_ = [block copy];
        return *this;
    }

    StubbedMethod & StubbedMethod::with(const Argument::shared_ptr_t argument) {
        this->add_argument(argument);
        return *this;
    };

    StubbedMethod & StubbedMethod::and_with(const Argument::shared_ptr_t argument) {
        return with(argument);
    }

    StubbedMethod & StubbedMethod::again() {
        this->is_override_ = true;
        return *this;
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

            if (!argument_ptr->matches(*other_argument_ptr)) {
                return false;
            }
        }
        return true;
    }

    bool StubbedMethod::arguments_equal(const StubbedMethod &other_stubbed_method) const {
        Cedar::Doubles::InvocationMatcher::arguments_vector_t arguments = this->arguments();
        Cedar::Doubles::InvocationMatcher::arguments_vector_t other_arguments = other_stubbed_method.arguments();

        auto arguments_size = std::max(arguments.size(), other_arguments.size());
        arguments.resize(arguments_size, Arguments::anything);
        other_arguments.resize(arguments_size, Arguments::anything);

        for (auto argument_it = arguments.begin(), other_argument_it = other_arguments.begin(); (argument_it != arguments.end() && other_argument_it != other_arguments.end()); ++argument_it, ++other_argument_it) {
            Cedar::Doubles::Argument::shared_ptr_t argument_ptr = (argument_it!=arguments.end()) ? *argument_it : Arguments::anything;
            Cedar::Doubles::Argument::shared_ptr_t other_argument_ptr = (other_argument_it!=other_arguments.end()) ? *other_argument_it : Arguments::anything;

            if ((*argument_ptr) != (*other_argument_ptr)) {
                return false;
            }
        }
        return true;
    }

    unsigned int StubbedMethod::arguments_specificity_ranking() const {
        Cedar::Doubles::InvocationMatcher::arguments_vector_t arguments = this->arguments();
        return std::accumulate(arguments.begin(), arguments.end(), 0, [](unsigned int sum, Cedar::Doubles::Argument::shared_ptr_t arg_ptr) {
            return sum+arg_ptr->specificity_ranking();
        });
    }

    void StubbedMethod::verify_return_value_type(id instance) const {
        if (this->has_return_value()) {
            const char * const methodReturnType = [[instance methodSignatureForSelector:this->selector()] methodReturnType];
            if (!this->return_value().compatible_with_encoding(methodReturnType)) {
                [[NSException exceptionWithName:NSInternalInconsistencyException
                                         reason:[NSString stringWithFormat:@"Invalid return value type '%@' instead of '%@' for <%@>", [CDRTypeUtilities typeNameForEncoding:this->return_value().value_encoding()], [CDRTypeUtilities typeNameForEncoding:methodReturnType], NSStringFromSelector(this->selector())]
                                       userInfo:nil] raise];
            }
        }
    }

    void StubbedMethod::verify_implementation_block_return_type(id instance) const {
        if (!this->has_implementation_block()) { return; }

        NSMethodSignature *instanceMethodSignature = [instance methodSignatureForSelector:this->selector()];
        NSMethodSignature *implementationBlockMethodSignature = [NSMethodSignature cdr_signatureFromBlock:implementation_block_];

        const char * const methodReturnType = [instanceMethodSignature methodReturnType];
        const char * const implementationBlockReturnType = [implementationBlockMethodSignature methodReturnType];
        if (0 != strcmp(implementationBlockReturnType, methodReturnType)) {
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"Invalid return type '%@' instead of '%@' for <%@>", [CDRTypeUtilities typeNameForEncoding:implementationBlockReturnType], [CDRTypeUtilities typeNameForEncoding:methodReturnType], NSStringFromSelector(this->selector())]
                                   userInfo:nil] raise];
        }
    }

    void StubbedMethod::verify_implementation_block_arguments(id instance) const {
        if (!this->has_implementation_block()) { return; }

        NSMethodSignature *instanceMethodSignature = [instance methodSignatureForSelector:this->selector()];
        NSMethodSignature *implementationBlockMethodSignature = [NSMethodSignature cdr_signatureFromBlock:implementation_block_];

        NSUInteger instanceMethodActualArgumentCount = [instanceMethodSignature numberOfArguments]-2;
        NSUInteger implementationBlockActualArgumentCount = [implementationBlockMethodSignature numberOfArguments]-1;

        if (instanceMethodActualArgumentCount != implementationBlockActualArgumentCount) {
            NSString * selectorString = NSStringFromSelector(this->selector());
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"Wrong number of parameters for <%@>; expected: %lu; actual: %lu (not counting the special first parameter, `id self`)", selectorString, (unsigned long)instanceMethodActualArgumentCount, (unsigned long)implementationBlockActualArgumentCount]
                                   userInfo:nil] raise];
        }

        for (NSInteger argIndex=2, blockArgIndex=1; argIndex<[instanceMethodSignature numberOfArguments]; argIndex++, blockArgIndex++) {
            const char * const instanceMethodArgumentType = [instanceMethodSignature getArgumentTypeAtIndex:argIndex];
            const char * const implementationBlockArgumentType = [implementationBlockMethodSignature getArgumentTypeAtIndex:blockArgIndex];
            if (0 != strcmp(instanceMethodArgumentType, implementationBlockArgumentType)) {
                NSString * selectorString = NSStringFromSelector(this->selector());
                [[NSException exceptionWithName:NSInternalInconsistencyException
                                         reason:[NSString stringWithFormat:@"Found argument type '%@', expected '%@'; argument #%lu for <%@>", [CDRTypeUtilities typeNameForEncoding:implementationBlockArgumentType], [CDRTypeUtilities typeNameForEncoding:instanceMethodArgumentType], (unsigned long)argIndex-1, selectorString]
                                       userInfo:nil] raise];
            }
        }
    }

    void StubbedMethod::validate_against_instance(id instance) const {
        this->verify_count_and_types_of_arguments(instance);
        this->verify_return_value_type(instance);
        this->verify_implementation_block_return_type(instance);
        this->verify_implementation_block_arguments(instance);
    }

    NSString * StubbedMethod::arguments_string() const {
        NSMutableString *argumentsString = [NSMutableString string];
        Cedar::Doubles::InvocationMatcher::arguments_vector_t arguments = this->arguments();
        Cedar::Doubles::InvocationMatcher::arguments_vector_t::iterator argument_it;
        for (argument_it = arguments.begin(); argument_it != arguments.end(); ++argument_it) {
            [argumentsString appendFormat:@"<%@>", (*argument_it)->value_string()];
        }
        return argumentsString;
    }

    void StubbedMethod::raise_for_multiple_return_values() const {
        NSString * selectorString = NSStringFromSelector(this->selector());
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"Multiple return values specified for <%@>", selectorString]
                               userInfo:nil] raise];
    }

    void StubbedMethod::raise_for_multiple_blocks() const {
        NSString * selectorString = NSStringFromSelector(this->selector());
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"Multiple blocks specified for <%@>", selectorString]
                               userInfo:nil] raise];
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
        } else if (this->has_implementation_block()) {
            [invocation cdr_invokeUsingBlockWithoutSelfArgument:implementation_block_];
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
