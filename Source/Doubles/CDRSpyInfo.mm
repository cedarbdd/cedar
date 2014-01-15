#import "CDRSpyInfo.h"
#import "CedarDoubleImpl.h"
#import <objc/runtime.h>

static NSMutableSet *currentSpies__;

@implementation CDRSpyInfo

+ (void)initialize {
    currentSpies__ = [[NSMutableSet alloc] init];
}

+ (void)storeSpyInfoForObject:(id)object {
    CDRSpyInfo *spyInfo = [[[CDRSpyInfo alloc] init] autorelease];
    spyInfo.originalObject = object;
    spyInfo.publicClass = [object class];
    spyInfo.spiedClass = object_getClass(object);
    spyInfo.cedarDouble = [[[CedarDoubleImpl alloc] initWithDouble:object] autorelease];
    spyInfo.callStack = [NSMutableArray array];
    [currentSpies__ addObject:spyInfo];
}

+ (BOOL)clearSpyInfoForObject:(id)object {
    CDRSpyInfo *spyInfo = [CDRSpyInfo spyInfoForObject:object];
    if (spyInfo) {
        spyInfo.originalObject = nil;
        [currentSpies__ removeObject:spyInfo];
        return YES;
    }
    return NO;
}

- (void)dealloc {
    if (self.originalObject) {
        object_setClass(self.originalObject, self.spiedClass);
    }
    self.originalObject = nil;
    self.cedarDouble = nil;
    self.callStack = nil;
    [super dealloc];
}

+ (CedarDoubleImpl *)cedarDoubleForObject:(id)object {
    return [[self spyInfoForObject:object] cedarDouble];
}

+ (Class)publicClassForObject:(id)object {
    return [[self spyInfoForObject:object] publicClass];
}

+ (CDRSpyInfo *)spyInfoForObject:(id)object {
    return [currentSpies__ objectsPassingTest:^BOOL(CDRSpyInfo *spyInfo, BOOL *stop) {
        if (spyInfo.originalObject == object) {
            *stop = YES;
            return YES;
        }
        return NO;
    }].anyObject;
}

- (IMP)impForSelector:(SEL)selector {
    BOOL yieldToKVO = (sel_isEqual(selector, @selector(addObserver:forKeyPath:options:context:)) ||
            sel_isEqual(selector, @selector(removeObserver:forKeyPath:)) ||
            sel_isEqual(selector, @selector(removeObserver:forKeyPath:context:)) ||
            sel_isEqual(selector, @selector(mutableArrayValueForKey:)) ||
            sel_isEqual(selector, @selector(mutableSetValueForKey:)) ||
            sel_isEqual(selector, @selector(mutableOrderedSetValueForKey:)) ||
            sel_isEqual(selector, @selector(willChange:valuesAtIndexes:forKey:)) ||
            sel_isEqual(selector, @selector(didChange:valuesAtIndexes:forKey:)) ||
            strcmp(class_getName(self.publicClass), class_getName(self.spiedClass)));
    if (yieldToKVO) {
        return NULL;
    }
    Method originalMethod = class_getInstanceMethod(self.spiedClass, selector);
    return method_getImplementation(originalMethod);
}

- (BOOL)isInvocationRepeatedInCallStack:(NSInvocation *)invocation {
    NSIndexSet *repeatedInvocationIndexSet = [self.callStack indexesOfObjectsPassingTest:^BOOL(NSInvocation *anInvocation, NSUInteger idx, BOOL *stop) {
        return sel_isEqual(anInvocation.selector, invocation.selector);
    }];
    // some magic constant to avoid infinite recursion to
    // defensive Apple-internal methods
    return repeatedInvocationIndexSet.count > 15;
}

- (void)addToCallStack:(NSInvocation *)invocation {
    [self.callStack addObject:invocation];
}

- (void)popCallStack {
    [self.callStack removeLastObject];
}

+ (void)afterEach {
    [currentSpies__ removeAllObjects];
}

@end
