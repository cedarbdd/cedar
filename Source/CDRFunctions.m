#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "CDRSpec.h"
#import "CDRExampleReporter.h"
#import "CDRDefaultReporter.h"
#import "SpecHelper.h"

BOOL CDRClassIsOfType(Class class, const char * const className) {
    if (strcmp(className, class_getName(class))) {
        while (class) {
            if (class_conformsToProtocol(class, NSProtocolFromString([NSString stringWithCString:className encoding:NSUTF8StringEncoding]))) {
                return YES;
            }
            class = class_getSuperclass(class);
        }
    }

    return NO;
}

NSArray *CDRSelectClasses(BOOL (^classSelectionPredicate)(Class class)) {
    unsigned int numberOfClasses = objc_getClassList(NULL, 0);
    Class classes[numberOfClasses];
    numberOfClasses = objc_getClassList(classes, numberOfClasses);

    NSMutableArray *selectedClasses = [NSMutableArray array];
    for (unsigned int i = 0; i < numberOfClasses; ++i) {
        Class class = classes[i];

        if (classSelectionPredicate(class)) {
            [selectedClasses addObject:class];
        }
    }
    return selectedClasses;
}

NSArray *CDRCreateRootGroupsFromSpecClasses(NSArray *specClasses) {
    NSMutableArray *rootGroups = [[NSMutableArray alloc] initWithCapacity:[specClasses count]];
    for (Class class in specClasses) {
        CDRSpec *spec = [[class alloc] init];
        [spec defineBehaviors];
        [rootGroups addObject:spec.rootGroup];
        [spec release];
    }
    return rootGroups;
}

void CDRDefineSharedExampleGroups() {
    NSArray *sharedExampleGroupPoolClasses = CDRSelectClasses(^(Class class) { return CDRClassIsOfType(class, "CDRSharedExampleGroupPool"); });
    for (Class class in sharedExampleGroupPoolClasses) {
        CDRSharedExampleGroupPool *sharedExampleGroupPool = [[class alloc] init];
        [sharedExampleGroupPool declareSharedExampleGroups];
        [sharedExampleGroupPool release];
    }
}

int runSpecsWithCustomExampleReporter(NSArray *specClasses, id<CDRExampleReporter> reporter) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    if (!specClasses) {
        specClasses = CDRSelectClasses(^(Class class) { return CDRClassIsOfType(class, "CDRSpec"); });
    }

    CDRDefineSharedExampleGroups();
    NSArray *groups = CDRCreateRootGroupsFromSpecClasses(specClasses);

    [reporter runWillStartWithGroups:groups];
    [groups makeObjectsPerformSelector:@selector(run)];
    [reporter runDidComplete];

    int result = [reporter result];

    [groups release];
    [pool drain];
    return result;
}

int runAllSpecs() {
    id<CDRExampleReporter> reporter = [[CDRDefaultReporter alloc] init];
    int result = runSpecsWithCustomExampleReporter(NULL, reporter);
    [reporter release];

    return result;
}
