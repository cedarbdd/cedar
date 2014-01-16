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
        // see -[CDRSpy release] method below to see why
        [instance retain];
    }
}

+ (void)stopInterceptingMessagesForInstance:(id)instance {
    if (!instance) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot stop spying on nil" userInfo:nil];
    }
    [CDRSpyInfo clearSpyInfoForObject:instance];
}

#pragma mark - Memory Management

// REASONING
//
// We need to know when to release our corresponding CDRSpyInfo to avoid leaking any memory.
// To do this, we need to keep track of retain counts to cleanup CDRSpyInfo once we hit
// zero.
//
// Fortunately, NSProxy has its own retain count mechanism that we can utilize to keep a
// "delta" from the original object's retain count to determine when we need to free spy
// info following some rules:
//
//  1. we can't let our NSProxy's retainCount from hitting zero via -[NSProxy release],
//     doing so will trigger a dealloc (which would be incorrect behavior).
//
//     - this is why we retain in +[CDRSpy interceptMessagesForInstance] as an extra +1
//
//  2. Since we can't count negative retainCount deltas because of #1, decrement the
//     original object's retainCount when NSProxy's retainCount == 1
//
//  3. When our total retain count is 1 (original + proxy), then we can release the spy
//     info and ourselves.
//
//

- (oneway void)release {
    CDRSpyInfo *info = [CDRSpyInfo spyInfoForObject:self];
    Class originalClass = info.spiedClass;
    if (originalClass != Nil) {
        Class spyClass = object_getClass(self);
        NSUInteger spyRetainCount = [super retainCount];
        object_setClass(self, originalClass);
        {
            NSUInteger originalRetainCount = [self retainCount];

            if (spyRetainCount == 1) {
                [self release];
                --originalRetainCount;
            } else {
                object_setClass(self, spyClass);
                [super release];
                object_setClass(self, originalClass);
            }

            if (originalRetainCount + spyRetainCount == 1) {
                info = [CDRSpyInfo spyInfoForObject:self];
                [info clear];
                [self release];
            } else {
                object_setClass(self, spyClass);
            }
        }
    }
}

- (id)autorelease {
    __block id that = self;
    [self as_spied_class:^{
        [that autorelease];
    }];
    return self;
}


#pragma mark - Emulating the original object

- (NSString *)description {
    __block id that = self;
    __block NSString *description = nil;
    [self as_spied_class:^{
        description = [that description];
    }];

    return description;
}

- (Class)class {
    return [CDRSpyInfo publicClassForObject:self];
}

- (BOOL)isKindOfClass:(Class)aClass {
    Class originalClass = [CDRSpyInfo publicClassForObject:self];
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

        SEL selector = invocation.selector;
        [self as_spied_class:^{
            forwardingTarget = [that forwardingTargetForSelector:selector];
        }];

        if (forwardingTarget) {
            [invocation invokeWithTarget:forwardingTarget];
        } else {
            CDRSpyInfo *spyInfo = [CDRSpyInfo spyInfoForObject:self];
            IMP privateImp = [spyInfo impForSelector:selector];
            if (privateImp) {
                [invocation invokeUsingIMP:privateImp];
            } else {
                __block id that = self;
                [self as_spied_class:^{
                    [invocation invoke];
                    [spyInfo setSpiedClass:object_getClass(that)];
                }];
            }
        }
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    __block NSMethodSignature *originalMethodSignature = nil;

    [self as_spied_class:^{
        originalMethodSignature = [self methodSignatureForSelector:sel];
    }];

    return originalMethodSignature;
}

- (BOOL)respondsToSelector:(SEL)selector {
    __block BOOL respondsToSelector = NO;

    [self as_spied_class:^{
        respondsToSelector = [self respondsToSelector:selector];
    }];

    return respondsToSelector;
}

- (void)doesNotRecognizeSelector:(SEL)selector {
    Class originalClass = [CDRSpyInfo publicClassForObject:self];
    NSString *exceptionReason = [NSString stringWithFormat:@"-[%@ %@]: unrecognized selector sent to spy %p", NSStringFromClass(originalClass), NSStringFromSelector(selector), self];
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:exceptionReason userInfo:nil];
}

#pragma mark - CedarDouble

- (BOOL)can_stub:(SEL)selector {
    return [self respondsToSelector:selector] && [self methodSignatureForSelector:selector];
}

- (Cedar::Doubles::StubbedMethod &)add_stub:(const Cedar::Doubles::StubbedMethod &)stubbed_method {
    return [self.cedar_double_impl add_stub:stubbed_method];
}

- (NSArray *)sent_messages {
    return self.cedar_double_impl.sent_messages;
}

- (void)reset_sent_messages {
    [self.cedar_double_impl reset_sent_messages];
}

#pragma mark - Private

- (CedarDoubleImpl *)cedar_double_impl {
    return [CDRSpyInfo cedarDoubleForObject:self];
}

- (void)as_class:(Class)klass :(void(^)())block {
    Class spyClass = object_getClass(self);
    object_setClass(self, klass);

    @try {
        block();
    } @finally {
        object_setClass(self, spyClass);
    }
}

- (void)as_spied_class:(void(^)())block {
    CDRSpyInfo *info = [CDRSpyInfo spyInfoForObject:self];
    Class originalClass = info.spiedClass;
    if (originalClass != Nil) {
        [self as_class:originalClass :block];
    }
}

@end
