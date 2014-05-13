#import "AnyInstanceConformingToProtocolArgument.h"

namespace Cedar { namespace Doubles {
    AnyInstanceConformingToProtocolArgument::AnyInstanceConformingToProtocolArgument(Protocol *protocol) : AnyInstanceArgument(), protocol_(protocol) {}

    /* virtual */ AnyInstanceConformingToProtocolArgument::~AnyInstanceConformingToProtocolArgument() {}

    /* virtual */ NSString * AnyInstanceConformingToProtocolArgument::value_string() const {
        return [NSString stringWithFormat:@"Any instance conforming to %@", NSStringFromProtocol(protocol_)];
    }

    /* virtual */ bool AnyInstanceConformingToProtocolArgument::matches_bytes(void * actual_argument_bytes) const {
        return actual_argument_bytes ? [*(static_cast<id *>(actual_argument_bytes)) conformsToProtocol:protocol_] : false;
    }

    /* virtual */ bool AnyInstanceConformingToProtocolArgument::matches(const Argument &other_argument) const {
        const AnyInstanceConformingToProtocolArgument *other_any_instance_argument = dynamic_cast<const AnyInstanceConformingToProtocolArgument *>(&other_argument);
        if (other_any_instance_argument) {
            return [protocol_ isEqual:other_any_instance_argument->protocol_];
        } else {
            return this->Argument::matches(other_argument);
        }
    }

    namespace Arguments {
        Argument::shared_ptr_t any(Protocol *protocol) {
            return Argument::shared_ptr_t(new AnyInstanceConformingToProtocolArgument(protocol));
        }
    }
    
}}
