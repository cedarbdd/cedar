#import "CDRClassFake.h"
#import <memory>
#import <map>
#import "objc/runtime.h"

namespace Cedar { namespace Doubles {

    struct SelCompare {
        bool operator() (const SEL& lhs, const SEL& rhs) const {
            return strcmp(sel_getName(lhs), sel_getName(rhs)) < 0;
        }
    };

    typedef std::shared_ptr<Cedar::Doubles::StubbedMethod> StubbedMethodPtr_t;
    typedef std::map<SEL, StubbedMethodPtr_t, SelCompare> StubbedMethodMap_t;

}}

@interface CDRClassFake () {
    std::auto_ptr<Cedar::Doubles::StubbedMethodPrototype> method_stubbing_;
    Cedar::Doubles::StubbedMethodMap_t stubbed_methods_;
}

@property (nonatomic, assign) Class klass;
@property (nonatomic, retain) NSMutableArray *sent_messages;

- (Cedar::Doubles::StubbedMethodPtr_t)stubbed_selector:(SEL)selector;

@end


@implementation CDRClassFake

@synthesize sent_messages = sent_messages_;
@synthesize klass = klass_;

- (id)initWithClass:(Class)klass {
    if (self = [super init]) {
        self.klass = klass;
        self.sent_messages = [NSMutableArray array];
        method_stubbing_ = std::auto_ptr<Cedar::Doubles::StubbedMethodPrototype>(new Cedar::Doubles::StubbedMethodPrototype(self));
        stubbed_methods_ = Cedar::Doubles::StubbedMethodMap_t();
    }
    return self;
}

- (void)dealloc {
    self.klass = nil;
    self.sent_messages = nil;
    [super dealloc];
}

- (BOOL)respondsToSelector:(SEL)selector {
    return true;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.klass instanceMethodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    Cedar::Doubles::StubbedMethodPtr_t stubbedMethod = [self stubbed_selector:invocation.selector];
    if (stubbedMethod) {
        [self.sent_messages addObject:invocation];
        if (stubbedMethod->has_return_value()) {
            const void * returnValue = stubbedMethod->return_value().value_bytes();
            [invocation setReturnValue:const_cast<void *>(returnValue)];
        }
    } else {
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Invocation of unstubbed method: %s", invocation.selector] userInfo:nil] raise];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Fake %@", self.klass];
}

#pragma mark - CedarDouble protocol

- (const Cedar::Doubles::StubbedMethodPrototype &)stub_method {
    return *method_stubbing_;
}

- (Cedar::Doubles::StubbedMethod &)create_stubbed_method_for:(SEL)selector {
    Cedar::Doubles::StubbedMethodMap_t::iterator it = stubbed_methods_.find(selector);
    if (it != stubbed_methods_.end()) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"The method '%s' is already stubbed", selector]
                               userInfo:nil] raise];
    }
    Cedar::Doubles::StubbedMethodPtr_t stubbed_method = Cedar::Doubles::StubbedMethodPtr_t(new Cedar::Doubles::StubbedMethod(selector, self));
    stubbed_methods_[selector] = stubbed_method;
    return *stubbed_method;
}

#pragma mark - Private methods

- (Cedar::Doubles::StubbedMethodPtr_t)stubbed_selector:(SEL)selector {
    Cedar::Doubles::StubbedMethodMap_t::iterator it = stubbed_methods_.find(selector);
    if (it != stubbed_methods_.end()) {
        return it->second;
    }
    return NULL;
}

@end
