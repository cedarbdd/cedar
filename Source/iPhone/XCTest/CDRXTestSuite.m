#import "CDRXTestSuite.h"
#import "CDRReportDispatcher.h"
#import <objc/runtime.h>

static CDRReportDispatcher *CDR_XCTestSuiteDispatcher;

@implementation CDRXTestSuite

+ (void)setDispatcher:(CDRReportDispatcher *)dispatcher {
    CDRReportDispatcher *oldValue = CDR_XCTestSuiteDispatcher;
    CDR_XCTestSuiteDispatcher = [dispatcher retain];
    [oldValue release];
}

- (void)performTest:(id)aRun {
    Class parentClass = class_getSuperclass([self class]);
    IMP superPerformTest = class_getMethodImplementation(parentClass, @selector(performTest:));
    ((void (*)(id instance, SEL cmd, id run))superPerformTest)(self, _cmd, aRun);

    [CDR_XCTestSuiteDispatcher runDidComplete];
}

@end
