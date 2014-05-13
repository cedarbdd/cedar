#import "AnyInstanceArgument.h"

namespace Cedar { namespace Doubles {
    /* virtual */ AnyInstanceArgument::~AnyInstanceArgument() {}

    /* virtual */ const char * const AnyInstanceArgument::value_encoding() const {
        return @encode(id);
    }

    /* virtual */ bool AnyInstanceArgument::matches_encoding(const char * actual_argument_encoding) const {
        return 0 == strncmp(actual_argument_encoding, "@", 1);
    }
}}
