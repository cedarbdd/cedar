#import "objc/runtime.h"
#import <vector>
#import "TypedArgument.h"

namespace Cedar { namespace Doubles {

    class InvocationMatcher {
    public:
        typedef std::vector<Argument::shared_ptr_t> arguments_vector_t;
        enum { OBJC_DEFAULT_ARGUMENT_COUNT = 2 };

    public:
        InvocationMatcher(const SEL);
        virtual ~InvocationMatcher() {}

        void add_argument(const Argument::shared_ptr_t argument);
        template<typename T>
        void add_argument(const T &);

        bool matches(NSInvocation * const) const;
        NSString *mismatch_reason();

        const SEL selector() const { return expectedSelector_; }
        const arguments_vector_t & arguments() const { return arguments_; }
        const bool match_any_arguments() const { return arguments_.empty(); }
        void verify_count_and_types_of_arguments(id instance) const;

    private:
        bool matches_arguments(NSInvocation * const) const;

    private:
        const SEL expectedSelector_;
        arguments_vector_t arguments_;
    };

    inline InvocationMatcher::InvocationMatcher(const SEL selector) :
        expectedSelector_(selector) {
    }

    inline void InvocationMatcher::add_argument(const Argument::shared_ptr_t argument) {
        arguments_.push_back(argument);
    }

    template<typename T>
    inline void InvocationMatcher::add_argument(const T & value) {
        this->add_argument(Argument::shared_ptr_t(new TypedArgument<T>(value)));
    }

    inline bool InvocationMatcher::matches(NSInvocation * const invocation) const {
        return sel_isEqual(invocation.selector, selector()) && this->matches_arguments(invocation);
    }

    inline void InvocationMatcher::verify_count_and_types_of_arguments(id instance) const {
        if (this->match_any_arguments()) {
            return;
        }

        NSMethodSignature *methodSignature = [instance methodSignatureForSelector:this->selector()];
        size_t actualArgumentCount = [methodSignature numberOfArguments] - OBJC_DEFAULT_ARGUMENT_COUNT;
        size_t expectedArgumentCount = this->arguments().size();

        if (actualArgumentCount != expectedArgumentCount) {
            NSString * selectorString = NSStringFromSelector(this->selector());
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"Wrong number of expected parameters for <%@>; expected: %lu, actual: %lu", selectorString, (unsigned long)expectedArgumentCount, (unsigned long)actualArgumentCount]
                                   userInfo:nil]
             raise];
        }

        size_t index = OBJC_DEFAULT_ARGUMENT_COUNT;
        for (arguments_vector_t::const_iterator cit = this->arguments().begin(); cit != this->arguments().end(); ++cit, ++index) {
            const char * actual_argument_encoding = [methodSignature getArgumentTypeAtIndex:index];
            if (!(*cit)->matches_encoding(actual_argument_encoding)) {
                NSString * selectorString = NSStringFromSelector(this->selector());
                NSString *reason = [NSString stringWithFormat:@"Attempt to compare expected argument <%@> with actual argument type %s; argument #%lu for <%@>",
                                    (*cit)->value_string(),
                                    actual_argument_encoding,
                                    (unsigned long)(index - OBJC_DEFAULT_ARGUMENT_COUNT + 1),
                                    selectorString];
                [[NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil] raise];
            }
        }
    }

#pragma mark - Private interface
    inline bool InvocationMatcher::matches_arguments(NSInvocation * const invocation) const {
        bool matches = true;
        size_t index = OBJC_DEFAULT_ARGUMENT_COUNT;
        for (arguments_vector_t::const_iterator cit = arguments_.begin(); cit != arguments_.end() && matches; ++cit, ++index) {
            const char *actualArgumentEncoding = [invocation.methodSignature getArgumentTypeAtIndex:index];
            NSUInteger actualArgumentSize;
            NSGetSizeAndAlignment(actualArgumentEncoding, &actualArgumentSize, nil);

            char actualArgumentBytes[actualArgumentSize];
            [invocation getArgument:&actualArgumentBytes atIndex:index];
            matches = (*cit)->matches_bytes(&actualArgumentBytes);
        }
        return matches;
    }
}}
