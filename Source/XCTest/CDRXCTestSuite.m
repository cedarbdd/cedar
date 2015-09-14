#import "CDRXCTestSuite.h"
#import "CDRSpecRun.h"
#import "CDRSpec.h"
#import "CDRXCTestSupport.h"
#import <objc/runtime.h>

const char *CDRSpecRunKey;

@interface CDRXCTestSuite (FromXCTest)
- (instancetype)initWithName:(NSString *)name;
- (void)addTest:(id)test;
@end

@interface CDRXCTestSuite ()
@property (nonatomic, retain) CDRSpecRun *specRun;
@end

@implementation CDRXCTestSuite

- (instancetype)initWithSpecRun:(CDRSpecRun *)specRun {
    if (self = [self initWithName:@"Cedar"]) {
        self.specRun = specRun;

        for (CDRSpec *spec in specRun.specs) {
            [self addTest:[spec testSuiteWithRandomSeed:specRun.seed dispatcher:specRun.dispatcher]];
        }
    }
    return self;
}

/// This is needed to allow for runtime lookup of the superclass
#define super_performTest(RUN) do { \
Class parentClass = class_getSuperclass([self class]); \
IMP superPerformTest = class_getMethodImplementation(parentClass, @selector(performTest:)); \
((void (*)(id instance, SEL cmd, id run))superPerformTest)(self, _cmd, RUN); \
} while(0);

- (void)performTest:(id)aRun {
    [self.specRun performSpecRun:^{
        super_performTest(aRun);
    }];
}

#pragma mark - Accessors

- (void)setSpecRun:(CDRSpecRun *)specRun {
    objc_setAssociatedObject(self, &CDRSpecRunKey, specRun, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CDRSpecRun *)specRun {
    return objc_getAssociatedObject(self, &CDRSpecRunKey);
}

@end
