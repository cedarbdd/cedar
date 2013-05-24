#import "CDRFake.h"
#import "CDRProtocolFake.h"
#import "objc/runtime.h"
#import "StubbedMethod.h"
#import "CedarDoubleImpl.h"

static bool CDRProtocolHasSelector(Protocol *protocol, SEL selector, BOOL is_required_method, BOOL is_instance_method) {
    objc_method_description method_description = protocol_getMethodDescription(protocol, selector, is_required_method, is_instance_method);
    return method_description.name && method_description.types;
}

static bool CDRGetProtocolMethodDescription(Protocol *p, SEL aSel, BOOL isRequiredMethod, BOOL isInstanceMethod, struct objc_method_description *outDesc) {
    *outDesc = protocol_getMethodDescription(p, aSel, isRequiredMethod, isInstanceMethod);
    return outDesc->types != NULL;
}

@interface CDRProtocolFake () {
    Protocol * protocol_;
}

@end

@implementation CDRProtocolFake

- (id)initWithClass:(Class)klass forProtocol:(Protocol *)protocol requireExplicitStubs:(bool)requireExplicitStubs {
    if (self = [super initWithClass:klass requireExplicitStubs:requireExplicitStubs]) {
        protocol_ = protocol;
    }
    return self;
}

- (void)dealloc {
    protocol_ = nil;
    [super dealloc];
}

- (BOOL)respondsToSelector:(SEL)selector {
    return CDRProtocolHasSelector(protocol_, selector, true, true) ||
    CDRProtocolHasSelector(protocol_, selector, true, false) ||
    CDRProtocolHasSelector(protocol_, selector, false, true) ||
    CDRProtocolHasSelector(protocol_, selector, false, false);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    struct objc_method_description methodDescription;
    
    if (CDRGetProtocolMethodDescription(protocol_, sel, true, true, &methodDescription) ||
        CDRGetProtocolMethodDescription(protocol_, sel, true, false, &methodDescription) ||
        CDRGetProtocolMethodDescription(protocol_, sel, false, true, &methodDescription) ||
        CDRGetProtocolMethodDescription(protocol_, sel, false, false, &methodDescription)) {
        
        return [NSMethodSignature signatureWithObjCTypes:methodDescription.types];
    } else {
        return nil;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Fake implementation of %s protocol", protocol_getName(protocol_)];
}

@end


id CDR_fake_for(Protocol *protocol, bool require_explicit_stubs /*= true*/) {
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
