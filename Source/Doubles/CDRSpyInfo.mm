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
    spyInfo.originalClass = [originalObject class];
    spyInfo.cedarDouble = [[[CedarDoubleImpl alloc] initWithDouble:originalObject] autorelease];
    [currentSpies__ addObject:spyInfo];
}

- (void)dealloc {
    object_setClass(self.originalObject, self.originalClass);
    self.originalObject = nil;
    self.cedarDouble = nil;
    [super dealloc];
}

+ (CedarDoubleImpl *)cedarDoubleForObject:(id)originalObject {
    return [[self spyInfoForObject:originalObject] cedarDouble];
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
