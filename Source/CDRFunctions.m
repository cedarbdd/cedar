#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "CDRSpec.h"
#import "CDRExampleReporter.h"
#import "CDRDefaultReporter.h"
#import "SpecHelper.h"

BOOL CDRClassIsSubclassOfClass(Class cls, Class superclass)
{
    if(cls == superclass) return NO;
    
    while(cls != nil)
    {
        cls = class_getSuperclass(cls);
        
        if(cls == superclass) return YES;
    }
    
    return NO;
}

NSArray *CDRAllSubclassesOfClass(Class cls)
{
    unsigned int numberOfClasses = objc_getClassList(NULL, 0);
    Class classes[numberOfClasses];
    numberOfClasses = objc_getClassList(classes, numberOfClasses);
    
    NSMutableArray *selectedClasses = [NSMutableArray array];
    for(unsigned int i = 0; i < numberOfClasses; ++i)
    {
        Class class = classes[i];
        
        if(CDRClassIsSubclassOfClass(class, cls))
            [selectedClasses addObject:class];
    }
    return selectedClasses;
}

NSArray *CDRCreateRootGroupsFromSpecClasses(NSArray *specClasses)
{
    NSMutableArray *rootGroups = [[NSMutableArray alloc] initWithCapacity:[specClasses count]];
    for(Class class in specClasses)
    {
        CDRSpec *spec = [[class alloc] init];
        [spec defineBehaviors];
        [rootGroups addObject:[spec rootGroup]];
        [spec release];
    }
    return rootGroups;
}

void CDRDefineSharedExampleGroups(void)
{
    for(Class class in CDRAllSubclassesOfClass([CDRSharedExampleGroupPool class]))
    {
        CDRSharedExampleGroupPool *sharedExampleGroupPool = [[class alloc] init];
        [sharedExampleGroupPool declareSharedExampleGroups];
        [sharedExampleGroupPool release];
    }
}

int runSpecsWithCustomExampleReporter(NSArray *specClasses, id<CDRExampleReporter> reporter)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    if(specClasses == nil) specClasses = CDRAllSubclassesOfClass([CDRSpec class]);

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

int runAllSpecs(void)
{
    id<CDRExampleReporter> reporter = [[CDRDefaultReporter alloc] init];
    int result = runSpecsWithCustomExampleReporter(NULL, reporter);
    [reporter release];

    return result;
}
