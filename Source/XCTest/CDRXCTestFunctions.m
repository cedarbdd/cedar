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

void CDRInjectIntoXCTestRunner() {
    Class testSuiteClass = NSClassFromString(@"XCTestSuite") ?: NSClassFromString(@"SenTestSuite");
    if (!testSuiteClass) {
        [[NSException exceptionWithName:@"CedarNoTestFrameworkAvailable" reason:@"You must link against either the XCTest or SenTestingKit frameworks." userInfo:nil] raise];
    }

    // if possible, use the new XCTestObservation protocol available in Xcode 7
    Class observationCenterClass = NSClassFromString(@"XCTestObservationCenter");
    if (observationCenterClass && [observationCenterClass respondsToSelector:@selector(sharedTestObservationCenter)]) {
        id observationCenter = [observationCenterClass sharedTestObservationCenter];
        static CDRXCTestObserver *xcTestObserver;
        xcTestObserver = [[CDRXCTestObserver alloc] init];
        [observationCenter addTestObserver:xcTestObserver];
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
