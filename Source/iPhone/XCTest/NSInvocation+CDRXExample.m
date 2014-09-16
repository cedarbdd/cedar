#import "NSInvocation+CDRXExample.h"
#import <objc/runtime.h>

const char *CDRXDispatcherKey;
const char *CDRXExampleKey;
const char *CDRXSpecClassNameKey;


@implementation NSInvocation (CDRXExample)

- (CDRReportDispatcher *)dispatcher {
    return objc_getAssociatedObject(self, &CDRXDispatcherKey);
}

- (void)setDispatcher:(CDRReportDispatcher *)dispatcher {
    objc_setAssociatedObject(self, &CDRXDispatcherKey, dispatcher, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CDRExample *)example {
    return objc_getAssociatedObject(self, &CDRXExampleKey);
}

- (void)setExample:(CDRExample *)example {
    objc_setAssociatedObject(self, &CDRXExampleKey, example, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)specClassName {
    return objc_getAssociatedObject(self, &CDRXSpecClassNameKey);
}

- (void)setSpecClassName:(NSString *)specClassName {
    objc_setAssociatedObject(self, &CDRXSpecClassNameKey, specClassName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
