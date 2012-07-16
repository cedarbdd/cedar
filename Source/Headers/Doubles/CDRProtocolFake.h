#import <Foundation/Foundation.h>
#import "CedarDouble.h"
#import "CDRFake.h"
#import "objc/runtime.h"

#import <sstream>
#import <string>

@interface CDRProtocolFake : CDRFake

- (id)initWithClass:(Class)klass forProtocol:(Protocol *)protocol requireExplicitStubs:(bool)requireExplicitStubs;

@end

inline id CDR_fake_for(Protocol *protocol, bool require_explicit_stubs = true) {
    static size_t protocol_dummy_class_id = 0;

    const char * protocol_name = protocol_getName(protocol);
    std::stringstream class_name_emitter;
    class_name_emitter << "fake for Protocol " << protocol_name << " #" << protocol_dummy_class_id++;

    Class klass = objc_allocateClassPair([CDRProtocolFake class], class_name_emitter.str().c_str(), 0);
    if(!klass) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"Failed to create class when faking protocol %s", protocol_name]
                               userInfo:nil] raise];
    }
    if(!class_addProtocol(klass, @protocol(CedarDouble))) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"Failed to add CedarDouble protocol class when faking protocol %s", protocol_name]
                               userInfo:nil] raise];
    }
    if (!class_addProtocol(klass, protocol)) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"Failed to fake protocol %s, unable to add protocol to fake object", protocol_name]
                               userInfo:nil] raise];
    }
    objc_registerClassPair(klass);

    return [[[CDRProtocolFake alloc] initWithClass:klass forProtocol:protocol requireExplicitStubs:require_explicit_stubs] autorelease];
}
