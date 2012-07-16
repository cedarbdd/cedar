#import "CedarDoubleImpl.h"
#import "StubbedMethod.h"
#import "StubbedMethodPrototype.h"

@interface CedarDoubleImpl () {
    std::auto_ptr<Cedar::Doubles::StubbedMethodPrototype> stubbed_method_prototype_;
    Cedar::Doubles::StubbedMethod::selector_map_t stubbed_methods_;
}

@property (nonatomic, retain, readwrite) NSMutableArray *sent_messages;
@property (nonatomic, assign) id<CedarDouble> parent_double;

@end

@implementation CedarDoubleImpl

@synthesize sent_messages = sent_messages_, parent_double = parent_double_;

- (id)init {
    [super doesNotRecognizeSelector:_cmd];
}

- (id)initWithDouble:(id<CedarDouble>)parent_double {
    if (self = [super init]) {
        stubbed_method_prototype_ = std::auto_ptr<Cedar::Doubles::StubbedMethodPrototype>(new Cedar::Doubles::StubbedMethodPrototype(parent_double));
        self.sent_messages = [NSMutableArray array];
        self.parent_double = parent_double;
    }
    return self;
}

- (void)dealloc {
    self.parent_double = nil;
    self.sent_messages = nil;
    [super dealloc];
}

- (Cedar::Doubles::StubbedMethodPrototype &)stubbed_method_prototype {
    return *stubbed_method_prototype_;
}

- (Cedar::Doubles::StubbedMethod::selector_map_t &)stubbed_methods {
    return stubbed_methods_;
}

- (Cedar::Doubles::StubbedMethod &)create_stubbed_method_for:(SEL)selector {
    Cedar::Doubles::StubbedMethod::selector_map_t::iterator it = stubbed_methods_.find(selector);
    if (it != stubbed_methods_.end()) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"The method <%s> is already stubbed", selector]
                               userInfo:nil] raise];
    }

    Cedar::Doubles::StubbedMethod::ptr_t stubbed_method_ptr = Cedar::Doubles::StubbedMethod::ptr_t(new Cedar::Doubles::StubbedMethod(selector, self.parent_double));
    stubbed_methods_[selector] = stubbed_method_ptr;
    return *stubbed_method_ptr;
}

- (BOOL)invoke_stubbed_method:(NSInvocation *)invocation {
    Cedar::Doubles::StubbedMethod::selector_map_t::iterator it = stubbed_methods_.find(invocation.selector);
    if (it == stubbed_methods_.end()) {
        return false;
    }

    Cedar::Doubles::StubbedMethod::ptr_t stubbed_method_ptr = it->second;
    if (stubbed_method_ptr->matches(invocation)) {
        [self record_method_invocation:invocation];
        stubbed_method_ptr->invoke(invocation);
        return true;
    } else {
        NSString * reason = [NSString stringWithFormat:@"Wrong arguments supplied to stub"];
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:reason
                               userInfo:nil] raise];
        return false;
    }
}

- (void)record_method_invocation:(NSInvocation *)invocation {
    [self.sent_messages addObject:invocation];
}

@end
