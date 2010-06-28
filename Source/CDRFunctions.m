#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "CDRSpec.h"
#import "CDRExampleReporter.h"
#import "CDRDefaultReporter.h"
#import "SpecHelper.h"

BOOL CDRIsASpecClass(Class class) {
    if (strcmp("CDRSpec", class_getName(class))) {
        while (class) {
            if (class_conformsToProtocol(class, NSProtocolFromString(@"CDRSpec"))) {
                return YES;
            }
            class = class_getSuperclass(class);
        }
    }

    return NO;
}

NSArray *CDREnumerateSpecClasses() {
    unsigned int numberOfClasses = objc_getClassList(NULL, 0);
    Class classes[numberOfClasses];
    numberOfClasses = objc_getClassList(classes, numberOfClasses);

    NSMutableArray *specClasses = [NSMutableArray array];
    for (unsigned int i = 0; i < numberOfClasses; ++i) {
        Class class = classes[i];
        if (CDRIsASpecClass(class)) {
            [specClasses addObject:class];
        }
    }
    return specClasses;
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

int runSpecsWithCustomExampleReporter(NSArray *specClasses, id<CDRExampleReporter> reporter) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    if (!specClasses) {
        specClasses = CDREnumerateSpecClasses();
    }
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
