#import <Foundation/Foundation.h>
#import <objc/objc-runtime.h>
#import "Cedar.h"
#import "CDRSpec.h"
#import "CDRExampleRunner.h"
#import "CDRDefaultRunner.h"

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

NSArray *CDRCreateSpecsFromSpecClasses(NSArray *specClasses) {
    NSMutableArray *specs = [[NSMutableArray alloc] initWithCapacity:[specClasses count]];
    for (Class class in specClasses) {
        CDRSpec *spec = [[class alloc] init];
        [spec defineBehaviors];
        [specs addObject:spec];
        [spec release];
    }
    return specs;
}

int runSpecsWithCustomExampleRunner(NSArray *specClasses, id<CDRExampleRunner> runner) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    if (!specClasses) {
        specClasses = CDREnumerateSpecClasses();
    }
    NSArray *specs = CDRCreateSpecsFromSpecClasses(specClasses);

    if ([runner respondsToSelector:@selector(runWillStartWithSpecs:)]) {
        [runner runWillStartWithSpecs:specs];
    }

    for (CDRSpec *spec in specs) {
        [spec runWithRunner:runner];
    }
    int result = [runner result];

    [specs release];
    [pool drain];
    return result;
}

int runAllSpecs() {
    id<CDRExampleRunner> runner = [[CDRDefaultRunner alloc] init];
    int result = runSpecsWithCustomExampleRunner(NULL, runner);
    [runner release];

    return result;
}
