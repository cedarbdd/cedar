#import "CedarDouble.h"
#import "CDRSpy.h"
#import "StubbedMethod.h"
#import <objc/runtime.h>

namespace Cedar { namespace Doubles {

    bool isCedarDouble(id instance) {
        Class clazz = object_getClass(instance);
        return ![NSStringFromClass(clazz) isEqual:@"ClassWithoutDescriptionMethod"] && [clazz conformsToProtocol:@protocol(CedarDouble)];
    }

    id<CedarDouble> operator,(id instance, const MethodStubbingMarker & marker) {
        if (!isCedarDouble(instance)) {
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"%@ is not a double", instance]
                                   userInfo:nil]
             raise];
        }
        return instance;
    }

    void operator,(id<CedarDouble> double_instance, const StubbedMethod & stubbed_method) {
        [double_instance add_stub:stubbed_method];
    }

}}
