#import "NSInvocation+Cedar.h"
#import "CDRSpy.h"
#import <objc/runtime.h>
#import "StubbedMethod.h"
#import "CedarDoubleImpl.h"
#import "CDRSpyInfo.h"

@interface NSInvocation (UndocumentedPrivate)
- (void)invokeUsingIMP:(IMP)imp;
@end

@implementation CDRSpy

+ (void)interceptMessagesForInstance:(id)instance {
    if (!instance) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot spy on nil" userInfo:nil];
    }
    if (![object_getClass(instance) conformsToProtocol:@protocol(CedarDouble)]) {
        [CDRSpyInfo storeSpyInfoForObject:instance];
        object_setClass(instance, self);
    }
}

+ (void)stopInterceptingMessagesForInstance:(id)instance {
    if (!instance) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot stop spying on nil" userInfo:nil];
    }
    Class originalClass = [instance class];
    if ([CDRSpyInfo clearSpyInfoForObject:instance]) {
        object_setClass(instance, originalClass);
    }
}

- (id)retain {
    __block id that = self;
    [self as_original_class:^{
        [that retain];
    }];
    return self;
}

- (oneway void)release {
    __block id that = self;
    [self as_original_class:^{
        [that release];
    }];
}

- (id)autorelease {
    __block id that = self;
    [self as_original_class:^{
        [that autorelease];
    }];
    return self;
}

- (NSUInteger)retainCount {
   __block id that = self;
   __block NSUInteger count;
   [self as_original_class:^{
       count = [that retainCount];
   }];
   return count;
}

- (NSString *)description {
    __block id that = self;
    __block NSString *description;
    [self as_original_class:^{
        description = [that description];
    }];

    return description;
}

- (Class)class {
    return [CDRSpyInfo originalClassForObject:self];
}

- (BOOL)isKindOfClass:(Class)aClass {
    Class originalClass = [CDRSpyInfo originalClassForObject:self];
    return [originalClass isSubclassOfClass:aClass];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [self.cedar_double_impl record_method_invocation:invocation];
    int method_invocation_result = [self.cedar_double_impl invoke_stubbed_method:invocation];

    [invocation copyBlockArguments];
    [invocation retainArguments];

    if (method_invocation_result != CDRStubMethodInvoked) {
        __block id forwardingTarget = nil;
        __block id that = self;

        [self as_original_class:^{
            forwardingTarget = [that forwardingTargetForSelector:invocation.selector];
        }];
        if (forwardingTarget) {
            [invocation invokeWithTarget:forwardingTarget];
        } else {
            Class originalClass = [CDRSpyInfo originalClassForObject:self];
            Method originalMethod = class_getInstanceMethod(originalClass, invocation.selector);

            if (originalMethod) {
                [invocation invokeUsingIMP:method_getImplementation(originalMethod)];
            } else {
                [self as_original_class:^{
                    [invocation invoke];
                }];
            }
        }
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    __block NSMethodSignature *originalMethodSignature;

    [self as_original_class:^{
        originalMethodSignature = [self methodSignatureForSelector:sel];
    }];

    return originalMethodSignature;
}

- (BOOL)respondsToSelector:(SEL)selector {
    __block BOOL respondsToSelector;

    [self as_original_class:^{
        respondsToSelector = [self respondsToSelector:selector];
    }];

    return respondsToSelector;
}

- (void)doesNotRecognizeSelector:(SEL)selector {
    Class originalClass = [CDRSpyInfo originalClassForObject:self];
    NSString *exceptionReason = [NSString stringWithFormat:@"-[%@ %@]: unrecognized selector sent to spy %p", NSStringFromClass(originalClass), NSStringFromSelector(selector), self];
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:exceptionReason userInfo:nil];
}

- (BOOL)can_stub:(SEL)selector {
    return [self respondsToSelector:selector] && [self methodSignatureForSelector:selector];
}

#pragma mark - CedarDouble protocol

- (Cedar::Doubles::StubbedMethod &)add_stub:(const Cedar::Doubles::StubbedMethod &)stubbed_method {
    return [self.cedar_double_impl add_stub:stubbed_method];
}

- (NSArray *)sent_messages {
    return self.cedar_double_impl.sent_messages;
}

- (void)reset_sent_messages {
    [self.cedar_double_impl reset_sent_messages];
}

- (void)get_argument:(void *)argument at_index:(NSUInteger)index for_last_invocation_of_selector:(SEL)selector {
    [self.cedar_double_impl get_argument:argument at_index:index for_last_invocation_of_selector:selector];
}

#pragma mark - Private interface

- (CedarDoubleImpl *)cedar_double_impl {
    return [CDRSpyInfo cedarDoubleForObject:self];
}

- (void)as_class:(Class)klass :(void(^)())block {
    block = [[block copy] autorelease];

    Class spyClass = object_getClass(self);
    object_setClass(self, klass);

    @try {
        block();
    } @finally {
        object_setClass(self, spyClass);
    }
}

- (void)as_original_class:(void(^)())block {
    Class originalClass = [CDRSpyInfo originalClassForObject:self];
    if (originalClass != Nil) {
        [self as_class:originalClass :block];
    }
}

@end
