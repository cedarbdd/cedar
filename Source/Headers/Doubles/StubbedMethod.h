#import <Foundation/Foundation.h>
#import <tr1/memory>
#import <vector>
#import "Argument.h"

namespace Cedar { namespace Doubles {

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

    private:
        NSMethodSignature *method_signature();

    private:
        SEL selector_;
        id parent_;
        std::auto_ptr<Argument> return_value_argument_;
        std::vector<std::tr1::shared_ptr<Argument> > arguments_;
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
        NSUInteger correct_number_of_arguments = [this->method_signature() numberOfArguments];
        if (arguments_.size() != correct_number_of_arguments) {
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

}}
