#import "NSInvocation+CDRXExample.h"
#import <objc/runtime.h>

const char *CDRXDispatcherKey;
const char *CDRXExamplesKey;
const char *CDRXSpecClassNameKey;


@implementation NSInvocation (CDRXExample)

- (CDRReportDispatcher *)cdr_dispatcher {
    return objc_getAssociatedObject(self, &CDRXDispatcherKey);
}

- (void)cdr_setDispatcher:(CDRReportDispatcher *)dispatcher {
    objc_setAssociatedObject(self, &CDRXDispatcherKey, dispatcher, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)cdr_examples {
    return objc_getAssociatedObject(self, &CDRXExamplesKey);
}

- (void)cdr_setExamples:(NSArray *)examples {
    objc_setAssociatedObject(self, &CDRXExamplesKey, examples, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)cdr_specClassName {
    return objc_getAssociatedObject(self, &CDRXSpecClassNameKey);
}

- (void)cdr_setSpecClassName:(NSString *)specClassName {
    objc_setAssociatedObject(self, &CDRXSpecClassNameKey, specClassName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cdr_addSupplementaryExample:(CDRExample *)example {
    NSArray *existingExamples = self.cdr_examples ?: @[];
    self.cdr_examples = [existingExamples arrayByAddingObject:example];
}

@end
