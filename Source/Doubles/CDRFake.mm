#import "NSInvocation+Cedar.h"
#import "CDRFake.h"
#import <objc/runtime.h>
#import "StubbedMethod.h"
#import "CedarDoubleImpl.h"

@interface CDRFake ()

@property (nonatomic, retain) CedarDoubleImpl *cedar_double_impl;

@end

@implementation CDRFake

@synthesize klass = klass_, cedar_double_impl = cedar_double_impl_, requiresExplicitStubs = requiresExplicitStubs_;

- (id)initWithClass:(Class)klass requireExplicitStubs:(BOOL)requireExplicitStubs {
    if (self = [super init]) {
        self.requiresExplicitStubs = requireExplicitStubs;
        self.klass = klass;
        self.cedar_double_impl = [[[CedarDoubleImpl alloc] initWithDouble:self] autorelease];
    }
    return self;
}

- (void)dealloc {
    self.klass = nil;
    self.cedar_double_impl = nil;
    [super dealloc];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    if ([self.cedar_double_impl has_rejected_method_for:sel]) {
        return nil;
    }
    return [self.klass instanceMethodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    @try {
        [self.cedar_double_impl record_method_invocation:invocation];
        CDRStubInvokeStatus method_invocation_result = [self.cedar_double_impl invoke_stubbed_method:invocation];
        switch (method_invocation_result) {
            case CDRStubMethodInvoked: {
                // do nothing; everything's cool
            } break;
            case CDRStubMethodNotStubbed: {
                if (self.requiresExplicitStubs) {
                    NSString * selectorString = NSStringFromSelector(invocation.selector);
                    [[NSException exceptionWithName:NSInternalInconsistencyException
                                             reason:[NSString stringWithFormat:@"Invocation of unstubbed method: %@", selectorString]
                                           userInfo:nil]
                     raise];
                }
            } break;
            case CDRStubWrongArguments: {
                if (self.requiresExplicitStubs) {
                    NSString * reason = [NSString stringWithFormat:@"Wrong arguments supplied to stub"];
                    [[NSException exceptionWithName:NSInternalInconsistencyException
                                             reason:reason
                                           userInfo:nil] raise];
                }
            } break;
            default:
                break;
        }

    } @finally {
        [invocation cdr_copyBlockArguments];
        [invocation retainArguments];
    }
}

#pragma mark - CedarDouble protocol

- (Cedar::Doubles::StubbedMethod &)add_stub:(const Cedar::Doubles::StubbedMethod &)stubbed_method {
    return [self.cedar_double_impl add_stub:stubbed_method];
}

- (void)reject_method:(const Cedar::Doubles::RejectedMethod &)rejected_method {
    [self.cedar_double_impl reject_method:rejected_method];
}

- (NSArray *)sent_messages {
    return self.cedar_double_impl.sent_messages;
}

- (NSArray *)sent_messages_with_selector:(SEL)selector {
    return [self.cedar_double_impl sent_messages_with_selector:selector];
}

- (void)reset_sent_messages {
    [self.cedar_double_impl reset_sent_messages];
}

- (BOOL)can_stub:(SEL)selector {
    return [self.klass instancesRespondToSelector:selector] && [self.klass instanceMethodSignatureForSelector:selector];
}

- (BOOL)has_stubbed_method_for:(SEL)selector {
    return [self.cedar_double_impl has_stubbed_method_for:selector];
}

- (BOOL)has_rejected_method_for:(SEL)selector {
    return [self.cedar_double_impl has_rejected_method_for:selector];
}

@end
