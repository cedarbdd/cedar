#import "CDRFake.h"
#import "CDRProtocolFake.h"
#import "objc/runtime.h"
#import "StubbedMethod.h"
#import "CedarDoubleImpl.h"

static bool protocol_hasSelector(Protocol *protocol, SEL selector, BOOL is_required_method, BOOL is_instance_method) {
    objc_method_description method_description = protocol_getMethodDescription(protocol, selector, is_required_method, is_instance_method);
    return method_description.name && method_description.types;
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
    return protocol_hasSelector(protocol_, selector, true, true) ||
    protocol_hasSelector(protocol_, selector, true, false) ||
    protocol_hasSelector(protocol_, selector, false, true) ||
    protocol_hasSelector(protocol_, selector, false, false);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Fake implementation of %s protocol", protocol_getName(protocol_)];
}

@end
