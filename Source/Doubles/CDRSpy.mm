#import "CDRSpy.h"
#import "objc/runtime.h"

@interface CDRSpy ()

- (void)as_original_object:(void(^)())block;
- (Cedar::Doubles::StubbedMethodPrototype *)stubbed_method_prototype_ptr;
- (Cedar::Doubles::StubbedMethodMap_t *)stubbed_methods_ptr;
- (Cedar::Doubles::StubbedMethodPtr_t)stubbed_selector:(SEL)selector;

@end


@implementation CDRSpy

+ (void)interceptMessagesForInstance:(id)instance {
    Class originalClass = [instance class];
    objc_setAssociatedObject(instance, @"original-class", originalClass, OBJC_ASSOCIATION_ASSIGN);

    NSMutableArray *sentMessages = [NSMutableArray array];
    objc_setAssociatedObject(instance, @"sent-messages", sentMessages, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    Cedar::Doubles::StubbedMethodPrototype * stubbedMethodPrototype = new Cedar::Doubles::StubbedMethodPrototype(instance);
    NSValue *stubbedMethodPrototypeContainer = [NSValue valueWithPointer:stubbedMethodPrototype];
    objc_setAssociatedObject(instance, @"stubbed-method-prototype", stubbedMethodPrototypeContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    Cedar::Doubles::StubbedMethodMap_t * stubbedMethods = new Cedar::Doubles::StubbedMethodMap_t();
    NSValue *stubbedMethodsContainer = [NSValue valueWithPointer:stubbedMethods];
    objc_setAssociatedObject(instance, @"stubbed-methods", stubbedMethodsContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    object_setClass(instance, self);
}

- (void)dealloc {
    // Manually destroy associated C++ objects, since ObjC memory cleanup won't call C++ destructors.
    delete self.stubbed_method_prototype_ptr;
    delete self.stubbed_methods_ptr;

    object_setClass(self, objc_getAssociatedObject(self, @"original-class"));
    // Call the destructor for the original object.
    [self dealloc];
    // DO NOT call the destructor on super, since the superclass has already
    // destroyed itself when the original class's destructor called [super dealloc].
    // This (no-op) line must be here to prevent the compiler from helpfully
    // generating an error that the method has no [super dealloc] call.
    if(0) { [super dealloc]; }
}

- (NSString *)description {
    __block NSString *description;
    [self as_original_object:^{
        description = [self description];
    }];

    return description;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSMutableArray *sentMessages = objc_getAssociatedObject(self, @"sent-messages");
    [sentMessages addObject:invocation];

    Cedar::Doubles::StubbedMethodPtr_t stubbedMethod = [self stubbed_selector:invocation.selector];
    if (stubbedMethod) {
        if (stubbedMethod->has_return_value()) {
            const void * returnValue = stubbedMethod->return_value().value_bytes();
            [invocation setReturnValue:const_cast<void *>(returnValue)];
        }
    } else {
        [self as_original_object:^{
            [invocation invoke];
        }];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    __block NSMethodSignature *originalMethodSignature;

    [self as_original_object:^{
        originalMethodSignature = [self methodSignatureForSelector:sel];
    }];

    return originalMethodSignature;
}

- (BOOL)respondsToSelector:(SEL)selector {
    __block BOOL respondsToSelector = sel_isEqual(selector, @selector(sent_messages));

    [self as_original_object:^{
        respondsToSelector = respondsToSelector || [self respondsToSelector:selector];
    }];

    return respondsToSelector;
}

- (NSArray *)sent_messages {
    return objc_getAssociatedObject(self, @"sent-messages");
}

#pragma mark - CedarDouble protocol
- (const Cedar::Doubles::StubbedMethodPrototype &)stub_method {
    return *self.stubbed_method_prototype_ptr;
}


- (Cedar::Doubles::StubbedMethod &)create_stubbed_method_for:(SEL)selector {
    Cedar::Doubles::StubbedMethodMap_t & stubbed_methods = *self.stubbed_methods_ptr;
    Cedar::Doubles::StubbedMethodMap_t::iterator it = stubbed_methods.find(selector);
    if (it != stubbed_methods.end()) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"The method '%s' is already stubbed", selector]
                               userInfo:nil] raise];
    }
    Cedar::Doubles::StubbedMethodPtr_t stubbed_method = Cedar::Doubles::StubbedMethodPtr_t(new Cedar::Doubles::StubbedMethod(selector, self));
    stubbed_methods[selector] = stubbed_method;
    return *stubbed_method;
}

#pragma mark - Private interface
- (void)as_original_object:(void(^)())block {
    Class spyClass = object_getClass(self);
    object_setClass(self, objc_getAssociatedObject(self, @"original-class"));

    @try {
        block();
    } @finally {
        object_setClass(self, spyClass);
    }
}

- (Cedar::Doubles::StubbedMethodPrototype *)stubbed_method_prototype_ptr {
    NSValue *stubbedMethodPrototypeContainer = objc_getAssociatedObject(self, @"stubbed-method-prototype");
    return static_cast<Cedar::Doubles::StubbedMethodPrototype *>(stubbedMethodPrototypeContainer.pointerValue);
}

- (Cedar::Doubles::StubbedMethodMap_t *)stubbed_methods_ptr {
    NSValue *stubbedMethodsContainer = objc_getAssociatedObject(self, @"stubbed-methods");
    return static_cast<Cedar::Doubles::StubbedMethodMap_t *>(stubbedMethodsContainer.pointerValue);
}

- (Cedar::Doubles::StubbedMethodPtr_t)stubbed_selector:(SEL)selector {
    Cedar::Doubles::StubbedMethodMap_t & stubbed_methods = *self.stubbed_methods_ptr;
    Cedar::Doubles::StubbedMethodMap_t::iterator it = stubbed_methods.find(selector);
    if (it != stubbed_methods.end()) {
        return it->second;
    }
    return NULL;
}

@end
