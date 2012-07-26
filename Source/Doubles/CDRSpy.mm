#import "CDRSpy.h"
#import "objc/runtime.h"
#import "StubbedMethod.h"
#import "CedarDoubleImpl.h"

@interface CDRSpy ()

- (void)as_original_object:(void(^)())block;
- (CedarDoubleImpl *)cedar_double_impl;

@end

static const NSString *foo = @"wibble";


@implementation CDRSpy

+ (void)interceptMessagesForInstance:(id)instance {
    Class originalClass = [instance class];
    objc_setAssociatedObject(instance, @"original-class", originalClass, OBJC_ASSOCIATION_ASSIGN);

    CedarDoubleImpl *cedar_double_impl = [[[CedarDoubleImpl alloc] initWithDouble:instance] autorelease];
    objc_setAssociatedObject(instance, @"cedar-double-implementation", cedar_double_impl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    object_setClass(instance, self);
}

- (void)dealloc {
    object_setClass(self, objc_getAssociatedObject(self, @"original-class"));

    [self dealloc];

    // DO NOT call the destructor on super, since the superclass has already
    // destroyed itself when the original class's destructor called [super dealloc].
    // This (no-op) line must be here to prevent the compiler from helpfully
    // generating an error that the method has no [super dealloc] call.
    if(0) { [super dealloc]; }
}

- (NSString *)description {
    __block NSString *description;
    [self as_original_object:^{
        description = [self description];
    }];

    return description;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [self.cedar_double_impl record_method_invocation:invocation];

    if (![self.cedar_double_impl invoke_stubbed_method:invocation]) {
        [self as_original_object:^{
            [invocation invoke];
        }];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    __block NSMethodSignature *originalMethodSignature;

    [self as_original_object:^{
        originalMethodSignature = [self methodSignatureForSelector:sel];
    }];

    return originalMethodSignature;
}

- (BOOL)respondsToSelector:(SEL)selector {
    __block BOOL respondsToSelector;

    [self as_original_object:^{
        respondsToSelector = [self respondsToSelector:selector];
    }];

    return respondsToSelector;
}

#pragma mark - CedarDouble protocol

- (Cedar::Doubles::StubbedMethod &)add_stub:(const Cedar::Doubles::StubbedMethod &)stubbed_method {
    return [self.cedar_double_impl add_stub:stubbed_method];
}

- (NSArray *)sent_messages {
    return self.cedar_double_impl.sent_messages;
}

#pragma mark - Private interface
- (void)as_original_object:(void(^)())block {
    Class spyClass = object_getClass(self);
    object_setClass(self, objc_getAssociatedObject(self, @"original-class"));

    @try {
        block();
    } @finally {
        object_setClass(self, spyClass);
    }
}

- (CedarDoubleImpl *)cedar_double_impl {
    return objc_getAssociatedObject(self, @"cedar-double-implementation");
}

@end
