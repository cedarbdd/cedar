#import "StubbedMethodPrototype.h"
#import "StubbedMethod.h"
#import "CedarDouble.h"

namespace Cedar { namespace Doubles {

    StubbedMethodPrototype::StubbedMethodPrototype(id<CedarDouble> parent) : parent_(parent) {
    }

    StubbedMethod & StubbedMethodPrototype::operator()(SEL selector) const {
        if ([parent_ respondsToSelector:selector]) {
            return [parent_ create_stubbed_method_for:selector];
        }
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"Attempting to stub method %s, which double does not respond to", selector]
                               userInfo:nil]
         raise];
    }

    StubbedMethod & StubbedMethodPrototype::operator()(const char * selector_name) const {
        return this->operator()(sel_registerName(selector_name));
    }

}}
