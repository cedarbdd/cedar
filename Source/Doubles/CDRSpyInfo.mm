#import "CDRSpyInfo.h"
#import "CedarDoubleImpl.h"
#import <objc/runtime.h>

static NSMutableSet *currentSpies__;

@implementation CDRSpyInfo

+ (void)initialize {
    currentSpies__ = [[NSMutableSet alloc] init];
}

+ (void)storeSpyInfoForObject:(id)originalObject {
    CDRSpyInfo *spyInfo = [[[CDRSpyInfo alloc] init] autorelease];
    spyInfo.originalObject = originalObject;
    spyInfo.originalClass = object_getClass(originalObject);
    spyInfo.cedarDouble = [[[CedarDoubleImpl alloc] initWithDouble:originalObject] autorelease];
    [currentSpies__ addObject:spyInfo];
}

+ (BOOL)clearSpyInfoForObject:(id)originalObject {
    CDRSpyInfo *spyInfo = [CDRSpyInfo spyInfoForObject:originalObject];
    if (spyInfo) {
        spyInfo.originalObject = nil;
        [currentSpies__ removeObject:spyInfo];
        return YES;
    }
    return NO;
}

+ (CDRSpyInfo *)spyInfoForSpiedObject:(id)object {
    return [currentSpies__ objectsPassingTest:^BOOL(CDRSpyInfo *spyInfo, BOOL *stop) {
        if (spyInfo.originalObject == object) {
            *stop = YES;
            return YES;
        }
        return NO;
    }].anyObject;
}

- (void)dealloc {
    if (self.originalObject) {
        object_setClass(self.originalObject, self.originalClass);
    }
    self.originalObject = nil;
    self.cedarDouble = nil;
    [super dealloc];
}

+ (CedarDoubleImpl *)cedarDoubleForObject:(id)originalObject {
    return [[self spyInfoForObject:originalObject] cedarDouble];
}

- (BOOL)isSpiedObjectUnderKVO {
    if (self.spiedClass == Nil) {
        return NO;
    }
    return strcmp(class_getName(self.originalClass), class_getName(self.spiedClass)) != 0;
}

+ (Class)originalClassForObject:(id)originalObject {
    return [[self spyInfoForObject:originalObject] originalClass];
}

+ (CDRSpyInfo *)spyInfoForObject:(id)originalObject {
    __block CDRSpyInfo *returnedSpyInfo = nil;
    [currentSpies__ enumerateObjectsUsingBlock:^(CDRSpyInfo *spyInfo, BOOL *stop) {
        if (spyInfo.originalObject == originalObject) {
            returnedSpyInfo = spyInfo;
            *stop = YES;
        }
    }];
    return returnedSpyInfo;
}

+ (void)afterEach {
    [currentSpies__ removeAllObjects];
}

@end
