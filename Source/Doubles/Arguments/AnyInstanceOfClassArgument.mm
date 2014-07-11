#import "AnyInstanceOfClassArgument.h"

namespace Cedar { namespace Doubles {
    AnyInstanceOfClassArgument::AnyInstanceOfClassArgument(const Class klass) : AnyInstanceArgument(), class_(klass) {}

    /* virtual */ AnyInstanceOfClassArgument::~AnyInstanceOfClassArgument() {}

    /* virtual */ NSString * AnyInstanceOfClassArgument::value_string() const {
        return [NSString stringWithFormat:@"Any instance of %@", class_];
    }

    /* virtual */ bool AnyInstanceOfClassArgument::matches_bytes(void * actual_argument_bytes) const {
        return actual_argument_bytes ? [*(static_cast<id *>(actual_argument_bytes)) isKindOfClass:class_] : false;
    }

    /* virtual */ bool AnyInstanceOfClassArgument::matches(const Argument &other_argument) const {
        const AnyInstanceOfClassArgument *other_any_instance_argument = dynamic_cast<const AnyInstanceOfClassArgument *>(&other_argument);
        if (other_any_instance_argument) {
            return [class_ isEqual:other_any_instance_argument->class_];
        } else {
            return this->Argument::matches(other_argument);
        }
    }

    namespace Arguments {
        Argument::shared_ptr_t any(Class klass) {
            return Argument::shared_ptr_t(new AnyInstanceOfClassArgument(klass));
        }
    }
    
}}
