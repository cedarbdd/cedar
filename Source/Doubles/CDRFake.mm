#import "CDRFake.h"
#import "objc/runtime.h"
#import "StubbedMethod.h"
#import "StubbedMethodPrototype.h"
#import "CedarDoubleImpl.h"

@interface CDRFake () {
    bool require_explicit_stubs_;
}

@property (nonatomic, retain) CedarDoubleImpl *cedar_double_impl;

@end

@implementation CDRFake

@synthesize klass = klass_, cedar_double_impl = cedar_double_impl_;

- (id)initWithClass:(Class)klass requireExplicitStubs:(bool)requireExplicitStubs {
    if (self = [super init]) {
        require_explicit_stubs_ = requireExplicitStubs;
        self.klass = klass;
        self.cedar_double_impl = [[[CedarDoubleImpl alloc] initWithDouble:self] autorelease];
    }
    return self;
}

- (void)dealloc {
    require_explicit_stubs_ = nil;
    self.klass = nil;
    self.cedar_double_impl = nil;
    [super dealloc];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.klass instanceMethodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [self.cedar_double_impl record_method_invocation:invocation];

    if (![self.cedar_double_impl invoke_stubbed_method:invocation]) {
        if (require_explicit_stubs_) {
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"Invocation of unstubbed method: %s", invocation.selector]
                                   userInfo:nil]
             raise];
        }
    }
}

#pragma mark - CedarDouble protocol

- (const Cedar::Doubles::StubbedMethodPrototype &)stub_method {
    return self.cedar_double_impl.stubbed_method_prototype;
}

- (Cedar::Doubles::StubbedMethod &)create_stubbed_method_for:(SEL)selector {
    return [self.cedar_double_impl create_stubbed_method_for:selector];
}

- (NSArray *)sent_messages {
    return self.cedar_double_impl.sent_messages;
}

@end
