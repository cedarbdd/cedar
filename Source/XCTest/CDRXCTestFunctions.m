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

static dispatch_once_t cedarTestSuiteCreatedOnceToken;

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

void chainClassMethod(Class metaClass, Class class, SEL selector, SEL newSelector, IMP newImplementation) {
    Method m = class_getClassMethod(class, selector);
    class_addMethod(metaClass, newSelector, method_getImplementation(m), method_getTypeEncoding(m));
    class_replaceMethod(metaClass, selector, newImplementation, method_getTypeEncoding(m));
}

void CDRInjectIntoXCTestRunner() {
    Class testSuiteClass = NSClassFromString(@"XCTestSuite") ?: NSClassFromString(@"SenTestSuite");
    if (!testSuiteClass) {
        [[NSException exceptionWithName:@"CedarNoTestFrameworkAvailable" reason:@"You must link against either the XCTest or SenTestingKit frameworks." userInfo:nil] raise];
    }
    Class testSuiteMetaClass = object_getClass(testSuiteClass);

    IMP newAllTestsImp = imp_implementationWithBlock(^id(id self, id testConfiguration){
        id defaultSuite = [self CDR_original_allTests];
        dispatch_once(&cedarTestSuiteCreatedOnceToken, ^{
            [defaultSuite addTest:CDRCreateXCTestSuite()];
        });
        return defaultSuite;
    });
    chainClassMethod(testSuiteMetaClass, testSuiteClass, @selector(allTests), @selector(CDR_original_allTests), newAllTestsImp);

    IMP newTestSuiteForConfigurationImp = imp_implementationWithBlock(^id(id self, id testConfiguration){
        id defaultSuite = [self CDR_original_testSuiteForTestConfiguration:testConfiguration];
        dispatch_once(&cedarTestSuiteCreatedOnceToken, ^{
            [defaultSuite addTest:CDRCreateXCTestSuite()];
        });
        return defaultSuite;
    });
    chainClassMethod(testSuiteMetaClass, testSuiteClass, @selector(testSuiteForTestConfiguration:), @selector(CDR_original_testSuiteForTestConfiguration:), newTestSuiteForConfigurationImp);
}
