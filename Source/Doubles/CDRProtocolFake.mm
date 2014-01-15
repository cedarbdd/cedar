#import "CDRFake.h"
#import "CDRProtocolFake.h"
#import "StubbedMethod.h"
#import <objc/runtime.h>

static bool protocol_hasSelector(Protocol *protocol, SEL selector, BOOL is_required_method, BOOL is_instance_method) {
    objc_method_description method_description = protocol_getMethodDescription(protocol, selector, is_required_method, is_instance_method);
    return method_description.name && method_description.types;
}

static bool CDR_protocol_hasSelector(Protocol *protocol, SEL selector) {
    return (protocol_hasSelector(protocol, selector, true, true)
            || protocol_hasSelector(protocol, selector, true, false)
            || protocol_hasSelector(protocol, selector, false, true)
            || protocol_hasSelector(protocol, selector, false, false));
}

@interface CDRProtocolFake ()
@property (retain, nonatomic) NSArray *protocols;
@end

@implementation CDRProtocolFake

@synthesize protocols = protocols_;

- (id)initWithClass:(Class)klass forProtocols:(NSArray *)protocols requireExplicitStubs:(BOOL)requireExplicitStubs; {
    if (self = [super initWithClass:klass requireExplicitStubs:requireExplicitStubs]) {
        self.protocols = protocols;
    }
    return self;
}

- (void)dealloc {
    self.protocols = nil;
    [super dealloc];
}

- (BOOL)can_stub:(SEL)selector {
    if (class_respondsToSelector(self.klass, selector)) {
        return YES;
    }
    for (Protocol *protocol in self.protocols) {
        if (CDR_protocol_hasSelector(protocol, selector)) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)respondsToSelector:(SEL)selector {
    if (class_respondsToSelector(self.klass, selector)) {
        return YES;
    }

    for (Protocol *protocol in self.protocols) {
        if ([self respondsToSelector:selector fromProtocol:protocol]) {
            return YES;
        }
    }
    return NO;
}

- (void)doesNotRecognizeSelector:(SEL)selector {
    if ([self has_rejected_method_for:selector]) {
        NSString *reason = [NSString stringWithFormat:@"Received message with explicitly rejected selector <%@>", NSStringFromSelector(selector)];
        [[NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil] raise];
    }
    [super doesNotRecognizeSelector:selector];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    for (Protocol *protocol in self.protocols) {
        if (protocol_conformsToProtocol(protocol, aProtocol)) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)description {
    NSMutableString *mutableDescription = [NSMutableString stringWithFormat:@"Fake implementation of %s", protocol_getName([self.protocols objectAtIndex:0])];
    NSUInteger protocolCount = [self.protocols count];
    for (int i = 1; i < protocolCount; i++) {
        [mutableDescription appendFormat:@", %s", protocol_getName([self.protocols objectAtIndex:i])];
    }
    [mutableDescription appendString:@" protocol(s)"];
    return [NSString stringWithString:mutableDescription];
}

- (BOOL)respondsToSelector:(SEL)selector fromProtocol:(Protocol *)protocol {
    if (protocol_hasSelector(protocol, selector, true, true) || protocol_hasSelector(protocol, selector, true, false)) {
        return YES;
    }
    if (self.requiresExplicitStubs) {
        return [self has_stubbed_method_for:selector];
    }
    else if ([self has_rejected_method_for:selector]) {
        return NO;
    }
    return protocol_hasSelector(protocol, selector, false, true);
}

@end


id CDR_fake_for(BOOL require_explicit_stubs, Protocol *protocol, ...) {
    static size_t protocol_dummy_class_id = 0;

    const char *protocol_name = protocol_getName(protocol);
    std::stringstream class_name_emitter;
    class_name_emitter << "Cedar fake for <" << protocol_name;

    NSMutableArray *protocolArray = [NSMutableArray arrayWithObject:protocol];

    va_list args;
    va_start(args, protocol);
    Protocol *p = nil;
    while ((p = va_arg(args, Protocol *))) {
        [protocolArray addObject:p];
        class_name_emitter << ", " << protocol_getName(p);
    }
    va_end(args);

    class_name_emitter << "> #" << protocol_dummy_class_id++;
    Class klass = objc_allocateClassPair([CDRProtocolFake class], class_name_emitter.str().c_str(), 0);

    if (!klass) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"Failed to create class when faking protocol %s", protocol_name]
                               userInfo:nil] raise];
    }

    if (!class_addProtocol(klass, @protocol(CedarDouble))) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"Failed to add CedarDouble protocol class when faking protocol %s", protocol_name]
                               userInfo:nil] raise];
    }

    for (Protocol *proto in protocolArray) {
        if (!class_addProtocol(klass, proto)) {
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"Failed to fake protocol %s, unable to add protocol to fake object", protocol_getName(proto)]
                                   userInfo:nil] raise];
        }
    }

    objc_registerClassPair(klass);

    return [[[CDRProtocolFake alloc] initWithClass:klass forProtocols:protocolArray requireExplicitStubs:require_explicit_stubs] autorelease];
}
