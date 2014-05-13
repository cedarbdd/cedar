#import "AnyInstanceArgument.h"

namespace Cedar { namespace Doubles {

    AnyInstanceArgument::AnyInstanceArgument(const Class klass) : Argument(), class_(klass) {}

    /* virtual */ AnyInstanceArgument::~AnyInstanceArgument() {}

    /* virtual */ const char * const AnyInstanceArgument::value_encoding() const {
        return @encode(id);
    }

    /* virtual */ NSString * AnyInstanceArgument::value_string() const {
        return [NSString stringWithFormat:@"Any instance of %@", class_];
    }

    /* virtual */ bool AnyInstanceArgument::matches_encoding(const char * actual_argument_encoding) const {
        return 0 == strncmp(actual_argument_encoding, "@", 1);
    }

    /* virtual */ bool AnyInstanceArgument::matches_bytes(void * actual_argument_bytes) const {
        return actual_argument_bytes ? [*(static_cast<id *>(actual_argument_bytes)) isKindOfClass:class_] : false;
    }

    /* virtual */ bool AnyInstanceArgument::matches(const Argument &other_argument) const {
        const AnyInstanceArgument *other_any_instance_argument = dynamic_cast<const AnyInstanceArgument *>(&other_argument);
        if (other_any_instance_argument) {
            return [class_ isEqual:other_any_instance_argument->class_];
        } else {
            return this->Argument::matches(other_argument);
        }
    }

    namespace Arguments {
        Argument::shared_ptr_t any(Class klass) {
            return Argument::shared_ptr_t(new AnyInstanceArgument(klass));
        }
    }

}}
