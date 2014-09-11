#import "CDRXTestSuite.h"
#import "CDRReportDispatcher.h"
#import <objc/runtime.h>

static CDRReportDispatcher *__CDR_XCTestSuiteDispatcher;

@implementation CDRXTestSuite

+ (void)setDispatcher:(CDRReportDispatcher *)dispatcher {
    CDRReportDispatcher *oldValue = __CDR_XCTestSuiteDispatcher;
    __CDR_XCTestSuiteDispatcher = [dispatcher retain];
    [oldValue release];
}

+ (CDRReportDispatcher *)dispatcher {
    return __CDR_XCTestSuiteDispatcher;
}

- (void)performTest:(id)aRun {
    Class parentClass = class_getSuperclass([self class]);
    IMP superPerformTest = class_getMethodImplementation(parentClass, @selector(performTest:));
    ((void (*)(id instance, SEL cmd, id run))superPerformTest)(self, _cmd, aRun);

    [__CDR_XCTestSuiteDispatcher runDidComplete];
}

@end
