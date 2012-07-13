#import "Argument.h"
#import <memory>

namespace Cedar { namespace Doubles { namespace Arguments {

    Argument::shared_ptr_t anything = Argument::shared_ptr_t(new Doubles::AnyArgument());

}}}
