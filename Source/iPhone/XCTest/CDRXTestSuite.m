#import "CDRXTestSuite.h"
#import "CDRReportDispatcher.h"
#import <objc/runtime.h>

const char *CDRXDispatcherKey;

@implementation CDRXTestSuite

- (void)setDispatcher:(CDRReportDispatcher *)dispatcher {
    objc_setAssociatedObject(self, &CDRXDispatcherKey, dispatcher, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CDRReportDispatcher *)dispatcher {
    return objc_getAssociatedObject(self, &CDRXDispatcherKey);
}

- (void)performTest:(id)aRun {
    Class parentClass = class_getSuperclass([self class]);
    IMP superPerformTest = class_getMethodImplementation(parentClass, @selector(performTest:));
    ((void (*)(id instance, SEL cmd, id run))superPerformTest)(self, _cmd, aRun);

    [[self dispatcher] runDidComplete];
}

@end
