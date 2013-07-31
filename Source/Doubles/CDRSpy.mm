#import "NSInvocation+Cedar.h"
#import "CDRSpy.h"
#import "objc/runtime.h"
#import "StubbedMethod.h"
#import "CedarDoubleImpl.h"
#import "CDRSpyInfo.h"

@implementation CDRSpy

+ (void)interceptMessagesForInstance:(id)instance {
    if (!instance) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot spy on nil" userInfo:nil];
    }
    [CDRSpyInfo storeSpyInfoForObject:instance];
    object_setClass(instance, self);
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

- (void)forwardInvocation:(NSInvocation *)invocation {
    @try {
        [self.cedar_double_impl record_method_invocation:invocation];
        int method_invocation_result = [self.cedar_double_impl invoke_stubbed_method:invocation];
        if (method_invocation_result != CDRStubMethodInvoked) {
            /* This *almost* works, but makes KVC and some UIKit classes unhappy. */
            //        [self as_class:[self createTransientClassForSelector:invocation.selector] :^{
            [self as_original_class:^{
                [invocation invoke];
            }];
        }
    } @finally {
        [invocation copyBlockArguments];
        [invocation retainArguments];
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

- (BOOL)can_stub:(SEL)selector {
    return [self respondsToSelector:selector];
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

- (Class)createTransientClassForSelector:(SEL)selector {
    Class klass = objc_allocateClassPair([CDRSpy class], [self.uniqueClassName cStringUsingEncoding:NSUTF8StringEncoding], 0);
    objc_registerClassPair(klass);

    Class originalClass = [CDRSpyInfo originalClassForObject:self];
    Method originalMethod = class_getInstanceMethod(originalClass, selector);

    /*
     Every now and then a method returns NULL for its implementation.  Since I have no
     idea why, or how to get around this in a generic way, fall back to the original
     class itself.  This will cause the spy to not record subsequent methods invoked
     on self, but hopefully this is rare enough to not cause a problem.

     The alternative is an EXC_BAD_ACCESS.
     */
    if (!originalMethod) {
        return originalClass;
    }

    class_addMethod(klass, selector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    return klass;
}

- (NSString *)uniqueClassName {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = [(NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid) autorelease];
    CFRelease(uuid);

    return [NSString stringWithFormat:@"CDRSpyTransientClass-%@", uuidStr];
}

@end
