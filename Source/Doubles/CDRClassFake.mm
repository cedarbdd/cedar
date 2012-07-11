#import "CDRClassFake.h"
#import "objc/runtime.h"
#import "StubbedMethod.h"
#import "StubbedMethodPrototype.h"
#import "CedarDoubleImpl.h"

@interface CDRClassFake ()

@property (nonatomic, retain) CedarDoubleImpl *cedar_double_impl;
@property (nonatomic, assign) Class klass;

@end


@implementation CDRClassFake

@synthesize klass = klass_, cedar_double_impl = cedar_double_impl_;

- (id)initWithClass:(Class)klass {
    if (self = [super init]) {
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

- (BOOL)respondsToSelector:(SEL)selector {
    return [self.klass instancesRespondToSelector:selector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.klass instanceMethodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [self.cedar_double_impl record_method_invocation:invocation];

    if (![self.cedar_double_impl invoke_stubbed_method:invocation]) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"Invocation of unstubbed method: %s", invocation.selector]
                               userInfo:nil]
         raise];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Fake %@", self.klass];
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
