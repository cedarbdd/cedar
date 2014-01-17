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
    [currentSpies__ addObject:spyInfo];
}

+ (BOOL)clearSpyInfoForObject:(id)object {
    CDRSpyInfo *spyInfo = [CDRSpyInfo spyInfoForObject:object];
    if (spyInfo) {
        [spyInfo clearSpy];
        return YES;
    }
    return NO;
}

- (void)clearSpy {
    if (self.originalObject) {
        [currentSpies__ removeObject:self];
        object_setClass(self.originalObject, self.spiedClass);
    }
}

- (void)dealloc {
    self.publicClass = nil;
    self.spiedClass = nil;
    self.originalObject = nil;
    self.cedarDouble = nil;
    [super dealloc];
}

+ (CedarDoubleImpl *)cedarDoubleForObject:(id)object {
    return [[self spyInfoForObject:object] cedarDouble];
}

+ (Class)publicClassForObject:(id)object {
    return [[self spyInfoForObject:object] publicClass];
}

+ (CDRSpyInfo *)spyInfoForObject:(id)object {
    for (CDRSpyInfo *spyInfo in currentSpies__) {
        if (spyInfo.originalObject == object) {
            return spyInfo;
        }
    }
    return nil;
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

+ (void)restoreAllSpies {
    [currentSpies__ makeObjectsPerformSelector:@selector(clearSpy)];
    [currentSpies__ removeAllObjects];
}

@end
