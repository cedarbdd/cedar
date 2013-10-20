#import "CDRFake.h"
#import "CDRProtocolFake.h"
#import "StubbedMethod.h"
#import <objc/runtime.h>

static bool protocol_hasSelector(Protocol *protocol, SEL selector, BOOL is_required_method, BOOL is_instance_method) {
    objc_method_description method_description = protocol_getMethodDescription(protocol, selector, is_required_method, is_instance_method);
    return method_description.name && method_description.types;
}

@interface CDRProtocolFake ()
@property (strong, nonatomic) Protocol *protocol;
@end

@implementation CDRProtocolFake

@synthesize protocol = protocol_;

- (id)initWithClass:(Class)klass forProtocol:(Protocol *)protocol requireExplicitStubs:(BOOL)requireExplicitStubs {
    if (self = [super initWithClass:klass requireExplicitStubs:requireExplicitStubs]) {
        protocol_ = protocol;
    }
    return self;
}

- (void)dealloc {
    protocol_ = nil;
    [super dealloc];
}

- (BOOL)can_stub:(SEL)selector {
    return class_respondsToSelector(self.klass, selector)
    || protocol_hasSelector(protocol_, selector, true, true)
    || protocol_hasSelector(protocol_, selector, true, false)
    || protocol_hasSelector(protocol_, selector, false, true)
    || protocol_hasSelector(protocol_, selector, false, false);
}

- (BOOL)respondsToSelector:(SEL)selector {
    return class_respondsToSelector(self.klass, selector)
    || protocol_hasSelector(protocol_, selector, true, true)
    || protocol_hasSelector(protocol_, selector, true, false)
    || (!self.requiresExplicitStubs && protocol_hasSelector(protocol_, selector, false, true))
    || (self.requiresExplicitStubs && [self has_stubbed_method_for:selector]);
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return protocol_conformsToProtocol(protocol_, aProtocol);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Fake implementation of %s protocol", protocol_getName(protocol_)];
}

@end


id CDR_fake_for(Protocol *protocol, BOOL require_explicit_stubs /*= YES */) {
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
