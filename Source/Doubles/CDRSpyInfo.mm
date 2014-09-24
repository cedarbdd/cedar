#import "CDRSpyInfo.h"
#import "CDRSpy.h"
#import "CedarDoubleImpl.h"
#import <objc/runtime.h>

static NSHashTable *currentSpies__;

@interface CDRSpyInfo ()
@property (nonatomic, assign) id originalObject;
@property (nonatomic, weak) id weakOriginalObject;
@end

@implementation CDRSpyInfo {
    __weak id _weakOriginalObject;
}

static char *CDRSpyKey;

+ (void)initialize {
    currentSpies__ = [[NSHashTable weakObjectsHashTable] retain];
}

+ (void)storeSpyInfoForObject:(id)object {
    CDRSpyInfo *spyInfo = [[[CDRSpyInfo alloc] init] autorelease];
    spyInfo.originalObject = object;
    spyInfo.weakOriginalObject = object;
    spyInfo.publicClass = [object class];
    spyInfo.spiedClass = object_getClass(object);
    spyInfo.cedarDouble = [[[CedarDoubleImpl alloc] initWithDouble:object] autorelease];

    [currentSpies__ addObject:spyInfo];
    objc_setAssociatedObject(object, &CDRSpyKey, spyInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (BOOL)clearSpyInfoForObject:(id)object {
    CDRSpyInfo *spyInfo = [CDRSpyInfo spyInfoForObject:object];
    if (spyInfo) {
        spyInfo.originalObject = nil;
        spyInfo.weakOriginalObject = nil;
        [currentSpies__ removeObject:spyInfo];
        objc_setAssociatedObject(object, &CDRSpyKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return YES;
    }
    return NO;
}

- (void)dealloc {
    self.publicClass = nil;
    self.spiedClass = nil;
    self.originalObject = nil;
    self.weakOriginalObject = nil;
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
    return objc_getAssociatedObject(object, &CDRSpyKey);
}

- (IMP)impForSelector:(SEL)selector {
    BOOL yieldToSpiedClass = (
        sel_isEqual(selector, @selector(addObserver:forKeyPath:options:context:)) ||
        sel_isEqual(selector, @selector(didChange:valuesAtIndexes:forKey:)) ||
        sel_isEqual(selector, @selector(mutableArrayValueForKey:)) ||
        sel_isEqual(selector, @selector(mutableOrderedSetValueForKey:)) ||
        sel_isEqual(selector, @selector(mutableSetValueForKey:)) ||
        sel_isEqual(selector, @selector(removeObserver:forKeyPath:)) ||
        sel_isEqual(selector, @selector(removeObserver:forKeyPath:context:)) ||
        sel_isEqual(selector, @selector(setValue:forKey:)) ||
        sel_isEqual(selector, @selector(valueForKey:)) ||
        sel_isEqual(selector, @selector(willChange:valuesAtIndexes:forKey:)) ||
        strcmp(class_getName(self.publicClass), class_getName(self.spiedClass))
    );

    if (yieldToSpiedClass) {
        return NULL;
    }

    Method originalMethod = class_getInstanceMethod(self.spiedClass, selector);
    return method_getImplementation(originalMethod);
}

+ (void)afterEach {
    for (CDRSpyInfo *spyInfo in [currentSpies__ allObjects]) {
        id originalObject = spyInfo.weakOriginalObject;
        if (originalObject) {
            Cedar::Doubles::CDR_stop_spying_on(originalObject);
        }
    }
}

#pragma mark - Accessors

- (id)weakOriginalObject {
    return objc_loadWeak(&_weakOriginalObject);
}

- (void)setWeakOriginalObject:(id)originalObject {
    objc_storeWeak(&_weakOriginalObject, originalObject);
}

@end
