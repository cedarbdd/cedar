#import "NSInvocation+CDRXExample.h"
#import <objc/runtime.h>

const char *CDRXDispatcherKey;
const char *CDRXExampleKey;
const char *CDRXSpecClassNameKey;


@implementation NSInvocation (CDRXExample)

- (CDRReportDispatcher *)cdr_dispatcher {
    return objc_getAssociatedObject(self, &CDRXDispatcherKey);
}

- (void)cdr_setDispatcher:(CDRReportDispatcher *)dispatcher {
    objc_setAssociatedObject(self, &CDRXDispatcherKey, dispatcher, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CDRExample *)cdr_example {
    return objc_getAssociatedObject(self, &CDRXExampleKey);
}

- (void)cdr_setExample:(CDRExample *)example {
    objc_setAssociatedObject(self, &CDRXExampleKey, example, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)cdr_specClassName {
    return objc_getAssociatedObject(self, &CDRXSpecClassNameKey);
}

- (void)cdr_setSpecClassName:(NSString *)specClassName {
    objc_setAssociatedObject(self, &CDRXSpecClassNameKey, specClassName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
