#import "CDRSpy.h"
#import "objc/runtime.h"

@interface CDRSpy ()

- (void)doAsOriginalObject:(void(^)())block;

@end


@implementation CDRSpy

+ (void)interceptMessagesForInstance:(id)instance {
    Class originalClass = [instance class];
    objc_setAssociatedObject(instance, @"original-class", originalClass, OBJC_ASSOCIATION_ASSIGN);

    NSMutableArray *sentMessages = [NSMutableArray array];
    objc_setAssociatedObject(instance, @"sent-messages", sentMessages, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    object_setClass(instance, self);
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSMutableArray *sentMessages = objc_getAssociatedObject(self, @"sent-messages");
    [sentMessages addObject:invocation];

    [self doAsOriginalObject:^{
        [invocation invoke];
    }];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    __block NSMethodSignature *originalMethodSignature = nil;
    [self doAsOriginalObject:^{
        originalMethodSignature = [self methodSignatureForSelector:sel];
    }];

    return originalMethodSignature;
}

- (BOOL)respondsToSelector:(SEL)selector {
    __block BOOL respondsToSelector = sel_isEqual(selector, @selector(sent_messages));

    [self doAsOriginalObject:^{
        respondsToSelector = respondsToSelector || [self respondsToSelector:selector];
    }];

    return respondsToSelector;
}

- (NSArray *)sent_messages {
    return objc_getAssociatedObject(self, @"sent-messages");
}

#pragma mark Private interface
- (void)doAsOriginalObject:(void(^)())block {
    Class spyClass = object_getClass(self);
    object_setClass(self, objc_getAssociatedObject(self, @"original-class"));

    block();

    object_setClass(self, spyClass);
}

@end
