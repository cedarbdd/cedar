#import "AnyArgument.h"


namespace Cedar { namespace Doubles {
    namespace Arguments {
        const Argument::shared_ptr_t anything = Argument::shared_ptr_t(new Doubles::AnyArgument());
    }
}}
