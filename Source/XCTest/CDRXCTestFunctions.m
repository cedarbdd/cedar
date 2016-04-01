#import <Foundation/Foundation.h>
#import "CDRFunctions.h"
#import "CDRPrivateFunctions.h"
#import "CDRXCTestSuite.h"
#import "CDRRuntimeUtilities.h"
#import "CDRXCTestObserver.h"
#import "CDRReportDispatcher.h"
#import "CDRSpec.h"
#import "CDRSpecRun.h"
#import <objc/runtime.h>

id CDRCreateXCTestSuite() {
    Class testSuiteClass = NSClassFromString(@"XCTestSuite") ?: NSClassFromString(@"SenTestSuite");
    Class testSuiteSubclass = NSClassFromString(@"_CDRXCTestSuite");

    if (testSuiteSubclass == nil) {
        testSuiteSubclass = [CDRRuntimeUtilities createMixinSubclassOf:testSuiteClass
                                                          newClassName:@"_CDRXCTestSuite"
                                                         templateClass:[CDRXCTestSuite class]];
    }

    CDRSpecRun *run = [[[CDRSpecRun alloc] initWithExampleReporters:CDRReportersToRun()] autorelease];
    return [[[testSuiteSubclass alloc] initWithSpecRun:run] autorelease];
}

void CDRAddCedarTestObserver(id observationCenter) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [observationCenter CDR_original_addTestObserver:[[CDRXCTestObserver alloc] init]];
    });
}

void CDRSwizzleTestSuiteAllTestsMethod() {
    Class testSuiteClass = NSClassFromString(@"XCTestSuite") ?: NSClassFromString(@"SenTestSuite");
    if (!testSuiteClass) {
        [[NSException exceptionWithName:@"CedarNoTestFrameworkAvailable" reason:@"You must link against either the XCTest or SenTestingKit frameworks." userInfo:nil] raise];
    }

    Class testSuiteMetaClass = object_getClass(testSuiteClass);
    Method m = class_getClassMethod(testSuiteClass, @selector(allTests));

    class_addMethod(testSuiteMetaClass, @selector(CDR_original_allTests), method_getImplementation(m), method_getTypeEncoding(m));
    IMP newImp = imp_implementationWithBlock(^id(id self){
        id defaultSuite = [self CDR_original_allTests];
        [defaultSuite addTest:CDRCreateXCTestSuite()];
        return defaultSuite;
    });
    class_replaceMethod(testSuiteMetaClass, @selector(allTests), newImp, method_getTypeEncoding(m));
}

void CDRSwizzleTestObservationCenter() {
    Class observationCenterClass = NSClassFromString(@"XCTestObservationCenter");
    if (observationCenterClass && [observationCenterClass respondsToSelector:@selector(sharedTestObservationCenter)]) {
        // Swizzle -addTestObserver:
        Method addTestObserverMethod = class_getInstanceMethod(observationCenterClass, @selector(addTestObserver:));
        class_addMethod(observationCenterClass, @selector(CDR_original_addTestObserver:), method_getImplementation(addTestObserverMethod), method_getTypeEncoding(addTestObserverMethod));

        IMP newAddTestObserverImp = imp_implementationWithBlock(^void(id self, id observer){
            [self CDR_original_addTestObserver:observer];
            CDRAddCedarTestObserver(self);
        });
        class_replaceMethod(observationCenterClass, @selector(addTestObserver:), newAddTestObserverImp, method_getTypeEncoding(addTestObserverMethod));


        // Swizzle -_addLegacyTestObserver:
        Method addLegacyTestObserverMethod = class_getInstanceMethod(observationCenterClass, @selector(_addLegacyTestObserver:));
        if (addLegacyTestObserverMethod) {
            class_addMethod(observationCenterClass, @selector(CDR_original__addLegacyTestObserver:), method_getImplementation(addLegacyTestObserverMethod), method_getTypeEncoding(addLegacyTestObserverMethod));

            IMP newAddLegacyTestObserverImp = imp_implementationWithBlock(^void(id self, id observer){
                [self CDR_original__addLegacyTestObserver:observer];
                CDRAddCedarTestObserver(self);
            });
            class_replaceMethod(observationCenterClass, @selector(_addLegacyTestObserver:), newAddLegacyTestObserverImp, method_getTypeEncoding(addLegacyTestObserverMethod));
        }
    }
}

void CDRInjectIntoXCTestRunner() {
    CDRSwizzleTestSuiteAllTestsMethod();
    CDRSwizzleTestObservationCenter();
}
