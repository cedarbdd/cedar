#import "CedarDoubleImpl.h"

static NSMutableArray *registeredDoubleImpls__ = nil;

@interface CedarDoubleImpl () {
    Cedar::Doubles::StubbedMethod::selector_map_t stubbed_methods_;
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

- (void)reset_sent_messages {
    [self.sent_messages removeAllObjects];
}

- (void)reject_method:(const Cedar::Doubles::RejectedMethod &)rejected_method {
    const SEL & selector = rejected_method.selector();

    if (![self can_stub:selector]) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"Attempting to reject method <%s>, which double <%@> already does not respond to", sel_getName(selector), [self.parent_double description]]
                               userInfo:nil]
         raise];
    }
    [self.rejected_methods addObject:NSStringFromSelector(rejected_method.selector())];
}

- (Cedar::Doubles::StubbedMethod &)add_stub:(const Cedar::Doubles::StubbedMethod &)stubbed_method {
    const SEL & selector = stubbed_method.selector();

    if (![self can_stub:selector]) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"Attempting to stub method <%s>, which double <%@> does not respond to", sel_getName(selector), [self.parent_double description]]
                               userInfo:nil]
         raise];
    }

    Cedar::Doubles::StubbedMethod::selector_map_t::iterator it = stubbed_methods_.find(selector);

    if (it != stubbed_methods_.end()) {
        Cedar::Doubles::StubbedMethod::stubbed_method_vector_t stubbed_methods = it->second;
        if (stubbed_method.contains_anything_argument()) {
            Cedar::Doubles::StubbedMethod::shared_ptr_t first_stubbed_method = stubbed_methods.front();
            if (first_stubbed_method->contains_anything_argument()) {
                [[NSException exceptionWithName:NSInternalInconsistencyException
                                         reason:[NSString stringWithFormat:@"The method <%s> is already stubbed with an 'anything' argument", sel_getName(selector)]
                                       userInfo:nil]
                 raise];
            } else {
                return [self add_stubbed_method:stubbed_method at_vector_location:stubbed_methods_[selector].begin()];
            }
        } else {
            Cedar::Doubles::StubbedMethod::stubbed_method_vector_t::iterator stubbed_method_it = stubbed_methods.begin();
            Cedar::Doubles::StubbedMethod::shared_ptr_t first_stubbed_method = stubbed_methods.front();
            if (first_stubbed_method->contains_anything_argument()) {
                // don't match stubbed_method against the first existing stubbed method, because the first one contains an 'anything' argument
                ++stubbed_method_it;
            }
            for (; stubbed_method_it != stubbed_methods.end(); ++stubbed_method_it) {
                if ((**stubbed_method_it).matches_arguments(stubbed_method)) {
                    [[NSException exceptionWithName:NSInternalInconsistencyException
                                             reason:[NSString stringWithFormat:@"The method <%s> is already stubbed with arguments %@", sel_getName(selector), stubbed_method.arguments_string()]
                                           userInfo:nil]
                     raise];
                }
            }
        }
    }
    return [self add_stubbed_method:stubbed_method at_vector_location:stubbed_methods_[selector].end()];
}

- (BOOL)can_stub:(SEL)selector {
    return [self.parent_double can_stub:selector];
}

- (CDRStubInvokeStatus)invoke_stubbed_method:(NSInvocation *)invocation {
    Cedar::Doubles::StubbedMethod::selector_map_t::iterator it = stubbed_methods_.find(invocation.selector);
    if (it == stubbed_methods_.end()) {
        return CDRStubMethodNotStubbed;
    }

    Cedar::Doubles::StubbedMethod::stubbed_method_vector_t stubbed_methods = it->second;

    Cedar::Doubles::StubbedMethod::stubbed_method_vector_t::reverse_iterator stubbed_method_it;
    for (stubbed_method_it = stubbed_methods.rbegin(); stubbed_method_it != stubbed_methods.rend(); ++stubbed_method_it) {
        Cedar::Doubles::StubbedMethod::shared_ptr_t stubbed_method_ptr = *stubbed_method_it;
        if (stubbed_method_ptr->matches(invocation)) {
            stubbed_method_ptr->invoke(invocation);
            return CDRStubMethodInvoked;
        }
    }
    return CDRStubWrongArguments;
}

- (BOOL)has_stubbed_method_for:(SEL)selector {
    Cedar::Doubles::StubbedMethod::selector_map_t::iterator it = stubbed_methods_.find(selector);
    return it != stubbed_methods_.end();
}

- (BOOL)has_rejected_method_for:(SEL)selector {
    return [self.rejected_methods containsObject:NSStringFromSelector(selector)];
}

- (void)record_method_invocation:(NSInvocation *)invocation {
    [self.sent_messages addObject:invocation];
}

#pragma mark - Private interface

- (Cedar::Doubles::StubbedMethod &)add_stubbed_method:(const Cedar::Doubles::StubbedMethod &)stubbed_method at_vector_location:(Cedar::Doubles::StubbedMethod::stubbed_method_vector_t::iterator)iterator {
    const SEL & selector = stubbed_method.selector();
    stubbed_method.validate_against_instance(self.parent_double);
    Cedar::Doubles::StubbedMethod::shared_ptr_t stubbed_method_ptr = Cedar::Doubles::StubbedMethod::shared_ptr_t(new Cedar::Doubles::StubbedMethod(stubbed_method));
    stubbed_methods_[selector].insert(iterator, stubbed_method_ptr);
    return *stubbed_method_ptr;
}

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

@end
