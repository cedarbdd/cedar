#import "CedarDouble.h"
#import "CDRSpy.h"
#import "StubbedMethod.h"
#import "RejectedMethod.h"
#import <objc/runtime.h>

namespace Cedar { namespace Doubles {

    id<CedarDouble> operator,(id instance, const MethodStubbingMarker & marker) {
        Class clazz = object_getClass(instance);
        if (![clazz conformsToProtocol:@protocol(CedarDouble)]) {
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

    void operator,(id<CedarDouble> double_instance, const RejectedMethod & rejected_method) {
        [double_instance reject_method:rejected_method];
    }

}}
