#import "CDRFake.h"
#import "CDRClassFake.h"
#import "objc/runtime.h"
#import "StubbedMethod.h"
#import "CedarDoubleImpl.h"

@interface CDRClassFake ()

@property (nonatomic, retain) CedarDoubleImpl *cedar_double_impl;

@end

@implementation CDRClassFake

- (BOOL)respondsToSelector:(SEL)selector {
    return [self.klass instancesRespondToSelector:selector];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Fake implementation of %@ class", self.klass];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [self.klass isSubclassOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [self.klass conformsToProtocol:aProtocol];
}

- (Class)class {
    return self.klass;
}

- (void)handleKVCSelector:(SEL)sel withValue:(id)value forKey:(NSString *)key {
    NSMethodSignature *signature = [self.klass methodSignatureForSelector:sel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:sel];
    [invocation setArgument:&value atIndex:2];
    [invocation setArgument:&key atIndex:3];
    [self.cedar_double_impl record_method_invocation:invocation];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([self has_stubbed_method_for:_cmd]) {
        [self handleKVCSelector:_cmd withValue:value forKey:key];
    } else {
        [self setValue:value forUndefinedKey:key];
    }
}

- (void)setValue:(id)value forKeyPath:(NSString *)key {
    if ([self has_stubbed_method_for:_cmd]) {
        [self handleKVCSelector:_cmd withValue:value forKey:key];
    } else {
        [self setValue:value forUndefinedKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if (self.requiresExplicitStubs) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"Attempting to set value <%@> for key <%@>, which must be stubbed first", value, key]
                               userInfo:nil] raise];
    }
}

@end

id CDR_fake_for(BOOL require_explicit_stubs, Class klass, ...) {
    va_list args;
    va_start(args, klass);
    if (va_arg(args, Class)) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:@"Can't create a fake for multiple classes."
                               userInfo:nil] raise];
    }
    va_end(args);

    return [[[CDRClassFake alloc] initWithClass:klass requireExplicitStubs:require_explicit_stubs] autorelease];
}
