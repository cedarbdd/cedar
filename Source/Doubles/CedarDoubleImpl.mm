#import "CedarDoubleImpl.h"

using namespace Cedar::Doubles;

static NSMutableArray *registeredDoubleImpls__ = nil;

@interface CedarDoubleImpl () {
    StubbedMethod::selector_map_t stubbed_methods_;
    NSMutableArray *sent_messages_;
    NSObject<CedarDouble> *parent_double_;
}

@property (nonatomic, retain, readwrite) NSMutableArray *sent_messages;
@property (nonatomic, retain) NSMutableArray *rejected_methods;
@property (nonatomic, assign) NSObject<CedarDouble> *parent_double;

@end

@implementation CedarDoubleImpl

@synthesize sent_messages = sent_messages_, parent_double = parent_double_;

+ (void)afterEach {
    [CedarDoubleImpl releaseRecordedInvocations];
}

- (id)init {
    [super doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithDouble:(NSObject<CedarDouble> *)parent_double {
    if (self = [super init]) {
        self.sent_messages = [NSMutableArray array];
        self.rejected_methods = [NSMutableArray array];
        self.parent_double = parent_double;
        [CedarDoubleImpl registerDoubleImpl:self];
    }
    return self;
}

- (void)dealloc {
    self.parent_double = nil;
    self.sent_messages = nil;
    self.rejected_methods = nil;
    [super dealloc];
}

- (NSArray *)sent_messages_with_selector:(SEL)selector {
    NSMutableArray *sentMessages = [[NSMutableArray alloc] initWithCapacity:self.sent_messages.count];

    for(NSInvocation *invocation in self.sent_messages) {
        if (invocation.selector == selector) {
            [sentMessages addObject:invocation];
        }
    }
    
    return [sentMessages autorelease];
}

- (void)reset_sent_messages {
    [self.sent_messages removeAllObjects];
}

- (void)reject_method:(const RejectedMethod &)rejected_method {
    const SEL & selector = rejected_method.selector();

    if (![self can_stub:selector]) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"Attempting to reject method <%s>, which double <%@> already does not respond to", sel_getName(selector), [self.parent_double description]]
                               userInfo:nil]
         raise];
    }
    [self.rejected_methods addObject:NSStringFromSelector(rejected_method.selector())];
}

- (StubbedMethod &)add_stub:(const StubbedMethod &)stubbed_method {
    const SEL & selector = stubbed_method.selector();

    if (![self can_stub:selector]) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"Attempting to stub method <%s>, which double <%@> does not respond to", sel_getName(selector), [self.parent_double description]]
                               userInfo:nil]
         raise];
    }

    stubbed_method.validate_against_instance(self.parent_double);

    if (stubbed_method.is_override()) {
        return [self override_stubbed_method:stubbed_method for_selector:selector];
    } else {
        return [self insert_stubbed_method:stubbed_method for_selector:selector];
    }
}

- (BOOL)can_stub:(SEL)selector {
    return [self.parent_double can_stub:selector];
}

- (BOOL)has_stubbed_method_for:(SEL)selector {
    StubbedMethod::selector_map_t::iterator it = stubbed_methods_.find(selector);
    return it != stubbed_methods_.end();
}

- (BOOL)has_rejected_method_for:(SEL)selector {
    return [self.rejected_methods containsObject:NSStringFromSelector(selector)];
}

- (CDRStubInvokeStatus)invoke_stubbed_method:(NSInvocation *)invocation {
    StubbedMethod::selector_map_t::iterator it = stubbed_methods_.find(invocation.selector);
    if (it == stubbed_methods_.end()) {
        return CDRStubMethodNotStubbed;
    }

    StubbedMethod::stubbed_method_vector_t stubbed_methods = it->second;
    for (auto stubbed_method_ptr : stubbed_methods) {
        if (stubbed_method_ptr->matches(invocation)) {
            stubbed_method_ptr->invoke(invocation);
            return CDRStubMethodInvoked;
        }
    }
    return CDRStubWrongArguments;
}

- (void)record_method_invocation:(NSInvocation *)invocation {
    [self.sent_messages addObject:invocation];
}

#pragma mark - Private interface

+ (void)releaseRecordedInvocations {
    [registeredDoubleImpls__ makeObjectsPerformSelector:@selector(reset_sent_messages)];
    [registeredDoubleImpls__ release];
    registeredDoubleImpls__ = nil;
}

+ (void)registerDoubleImpl:(CedarDoubleImpl *)doubleImpl {
    if (!registeredDoubleImpls__) {
        registeredDoubleImpls__ = [[NSMutableArray alloc] init];
    }
    [registeredDoubleImpls__ addObject:doubleImpl];
}

- (StubbedMethod &)insert_stubbed_method:(StubbedMethod const &)stubbed_method for_selector:(SEL const &)selector {
    StubbedMethod::stubbed_method_vector_t &stubbed_methods = stubbed_methods_[selector];
    for (auto stubbed_method_ptr : stubbed_methods) {
        if (stubbed_method_ptr->arguments_equal(stubbed_method)) {
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"The method <%s> is already stubbed with arguments (%@) - use again() to override", sel_getName(selector), stubbed_method_ptr->arguments_string()]
                                   userInfo:nil]
             raise];
        }
    }

    StubbedMethod::shared_ptr_t stubbed_method_ptr = StubbedMethod::shared_ptr_t(new StubbedMethod(stubbed_method));
    stubbed_methods.insert(stubbed_methods.begin(), stubbed_method_ptr);
    stable_sort(stubbed_methods.begin(), stubbed_methods.end(), [](StubbedMethod::shared_ptr_t lhs, StubbedMethod::shared_ptr_t rhs) {
        return lhs->arguments_specificity_ranking() > rhs->arguments_specificity_ranking();
    });
    return *stubbed_method_ptr;
}

- (StubbedMethod &)override_stubbed_method:(StubbedMethod const &)stubbed_method for_selector:(SEL const &)selector {
    StubbedMethod::stubbed_method_vector_t &stubbed_methods = stubbed_methods_[selector];
    StubbedMethod::shared_ptr_t found_stubbed_method_ptr = nullptr;
    for (auto stubbed_method_ptr : stubbed_methods) {
        if (stubbed_method_ptr->arguments_equal(stubbed_method)) {
            found_stubbed_method_ptr = stubbed_method_ptr;
            break;
        }
    }
    if (found_stubbed_method_ptr == nullptr) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"The method <%s> is not stubbed with arguments (%@) - again() should only be used to override a stubbed method.", sel_getName(selector), stubbed_method.arguments_string()]
                               userInfo:nil]
         raise];
    }
    StubbedMethod::shared_ptr_t stubbed_method_ptr = StubbedMethod::shared_ptr_t(new StubbedMethod(stubbed_method));
    replace(stubbed_methods.begin(), stubbed_methods.end(), found_stubbed_method_ptr, stubbed_method_ptr);
    return *stubbed_method_ptr;
}

@end
