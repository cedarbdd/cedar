#import "CDRClassProtocolFake.h"
#import "CDRClassFake.h"
#import <objc/runtime.h>

@interface CDRProtocolFake (InheritedPrivateMethods)

@property (retain, nonatomic) NSArray *protocols;

@end

@interface CDRClassProtocolFake ()

@property (retain, nonatomic) CDRClassFake *classFake;

@end

@implementation CDRClassProtocolFake

- (void)dealloc {
    self.classFake = nil;
    [super dealloc];
}

- (instancetype)initWithClass:(Class)baseClass fakedClass:(Class)fakedClass forProtocols:(NSArray *)protocolArray requireExplicitStubs:(BOOL)require_explicit_stubs {
    if (self = [super initWithClass:baseClass forProtocols:protocolArray requireExplicitStubs:require_explicit_stubs]) {
        self.classFake = [[[CDRClassFake alloc] initWithClass:fakedClass requireExplicitStubs:require_explicit_stubs] autorelease];
    }
    return self;
}

- (NSString *)description {
    NSMutableString *fakedDescription = [NSMutableString stringWithFormat:@"%@ class", self.classFake.klass];
    if (self.proto)
    for (Protocol *protocol in self.protocols) {

    }
    return [NSString stringWithFormat:@"Fake implementation of %@", fakedDescription];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector] || [self.classFake respondsToSelector:aSelector];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [self.classFake isKindOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [super conformsToProtocol:aProtocol] || [self.classFake conformsToProtocol:aProtocol];
}

- (Class)class {
    return [self.classFake class];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    [self.classFake setValue:value forKey:key];
}

- (void)setValue:(id)value forKeyPath:(NSString *)key {
    [self.classFake setValue:value forKeyPath:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    [self.classFake setValue:value forUndefinedKey:key];
}

- (BOOL)can_stub:(SEL)selector {
    return [super can_stub:selector] || [self.classFake can_stub:selector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *methodSignature = [super methodSignatureForSelector:aSelector];
    if (!methodSignature) {
        return [self.classFake methodSignatureForSelector:aSelector];
    }
    return methodSignature;
}

@end

id CDR_fake_for(BOOL require_explicit_stubs, Class fakedClass, ...) {
    static size_t protocol_dummy_class_id = 0;

    std::stringstream class_name_emitter;
    class_name_emitter << "Cedar fake for " << class_getName(fakedClass) << "<";

    NSMutableArray *protocolArray = [NSMutableArray array];

    va_list args;
    va_start(args, fakedClass);
    Protocol *p = nil;
    NSInteger additionalInterfaceIndex = 0;
    while ((p = va_arg(args, Protocol *))) {
        const char *protocol_name = protocol_getName(p);
        if (protocol_name && objc_getProtocol(protocol_name)) {
            [protocolArray addObject:p];
            if (additionalInterfaceIndex ++) {
                class_name_emitter << ", ";
            }
            class_name_emitter << protocol_getName(p);
        } else {
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"Additional interface #%@ to fake for class %s is not a valid protocol", @(additionalInterfaceIndex + 1), class_getName(fakedClass)]
                                   userInfo:nil] raise];
        }
    }
    va_end(args);

    class_name_emitter << "> #" << protocol_dummy_class_id++;
    Class klass = objc_allocateClassPair([CDRProtocolFake class], class_name_emitter.str().c_str(), 0);

    if (!klass) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"Failed to create class when creating %s", class_name_emitter.str().c_str()]
                               userInfo:nil] raise];
    }

    if (!class_addProtocol(klass, @protocol(CedarDouble))) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"Failed to add CedarDouble protocol when creating %s", class_name_emitter.str().c_str()]
                               userInfo:nil] raise];
    }

    for (Protocol *proto in protocolArray) {
        if (!class_addProtocol(klass, proto)) {
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"Failed to add protocol %s to %s", protocol_getName(proto), class_name_emitter.str().c_str()]
                                   userInfo:nil] raise];
        }
    }

    objc_registerClassPair(klass);

    return [[CDRClassProtocolFake alloc] initWithClass:klass fakedClass:fakedClass forProtocols:protocolArray requireExplicitStubs:require_explicit_stubs];
}
