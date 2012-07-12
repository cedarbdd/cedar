#import <Foundation/Foundation.h>
#import <tr1/memory>
#import <vector>
#import "Argument.h"

namespace Cedar { namespace Doubles {

    static const size_t NON_USER_ARGUMENTS = 2;

    class StubbedMethod {
    private:
        StubbedMethod(const StubbedMethod & );
        StubbedMethod & operator=(const StubbedMethod &);

    public:
        StubbedMethod(SEL, id);

        template<typename T>
        StubbedMethod & and_return(const T &);

        template<typename T>
        StubbedMethod & with(const T &);
        template<typename T>
        StubbedMethod & and_with(const T &);

        bool has_return_value() const { return return_value_argument_.get(); };
        Argument & return_value() const { return *return_value_argument_; };

        struct SelCompare {
            bool operator() (const SEL& lhs, const SEL& rhs) const {
                return strcmp(sel_getName(lhs), sel_getName(rhs)) < 0;
            }
        };
        typedef std::tr1::shared_ptr<StubbedMethod> ptr_t;
        typedef std::map<SEL, ptr_t, SelCompare> selector_map_t;

        bool invoke(NSInvocation * invocation) const;

    private:
        NSMethodSignature *method_signature();

    private:
        SEL selector_;
        id parent_;
        typedef std::vector<std::tr1::shared_ptr<Argument> > argument_list_t;
        std::auto_ptr<Argument> return_value_argument_;
        argument_list_t arguments_;
    };

    inline StubbedMethod::StubbedMethod(SEL selector, id parent)
    : selector_(selector), parent_(parent), return_value_argument_(0) {
    }

    template<typename T>
    StubbedMethod & StubbedMethod::and_return(const T & return_value) {
        if (strcmp([this->method_signature() methodReturnType], @encode(T))) {
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"Invalid return value type (%s) for %s", @encode(T), selector_]
                                   userInfo:nil] raise];
        }
        return_value_argument_ = std::auto_ptr<Argument>(new TypedArgument<T>(return_value));
    }

    template<typename T>
    StubbedMethod & StubbedMethod::with(const T & argument) {
        NSUInteger correct_number_of_arguments = [this->method_signature() numberOfArguments] - NON_USER_ARGUMENTS;
        if (arguments_.size() >= correct_number_of_arguments) {
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"Selector %s accepts %d arguments; stub expects too many.", selector_, correct_number_of_arguments]
                                   userInfo:nil] raise];
        }
        arguments_.push_back(std::tr1::shared_ptr<Argument>(new TypedArgument<T>(argument)));
        return *this;
    }

    template<typename T>
    StubbedMethod & StubbedMethod::and_with(const T & argument) {
        return with(argument);
    }

    inline NSMethodSignature *StubbedMethod::method_signature() {
        return [parent_ methodSignatureForSelector:selector_];
    }

    inline bool StubbedMethod::invoke(NSInvocation * invocation) const {
        if (has_return_value()) {
            const void * returnValue = return_value().value_bytes();
            [invocation setReturnValue:const_cast<void *>(returnValue)];
        }

        // Compiler cries about unused value in test part of for invocation if we try to initialize two values, possible compiler bug?
        size_t index = NON_USER_ARGUMENTS;
        std::vector<unsigned char> actualArgument;
        for (argument_list_t::const_iterator it = arguments_.begin(); it != arguments_.end(); ++it, ++index) {
            actualArgument.reserve((*it)->value_size());
            [invocation getArgument:&actualArgument[0] atIndex:index];

            if (!(*it)->matches_bytes(&actualArgument[0])) {
                NSString * reason = [NSString stringWithFormat:@"Wrong value supplied to %dth argument of stubbed method %s expected %@.", // got %@.",
                                        index - NON_USER_ARGUMENTS,
                                        invocation.selector,
                                     (*it)->value_string()];
                // TODO: Better printing for the actual value
                // Matchers::Stringifiers::string_for(&actualArgument[0], (*it)->value_encoding())];

                [[NSException exceptionWithName:NSInternalInconsistencyException
                                         reason:reason
                                       userInfo:nil] raise];
            }
        }

        return true;
    }

}}
