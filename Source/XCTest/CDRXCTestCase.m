#import "CDRXCTestCase.h"
#import "CDRExample.h"
#import "NSInvocation+CDRXExample.h"
#import <objc/runtime.h>


const char *CDRXTestInvocationsKey;

@interface CDRXCTestCase (XCTestCaseMethods)

@property (strong) NSInvocation *invocation; // defined by XCTestCase

- (void)recordFailureWithDescription:(NSString *)description inFile:(NSString *)filename atLine:(NSUInteger)lineNumber expected:(BOOL)expected;

@end

@implementation CDRXCTestCase

- (NSString *)name {
    return [NSString stringWithFormat:@"-[%@ %@]",
            [self testClassName],
            [self testMethodName]];
}

- (NSString *)testClassName {
    return [[self invocation] cdr_specClassName];
}

- (NSString *)testMethodName {
    return NSStringFromSelector([[self invocation] selector]);
}

- (void)invokeTest {
    NSInvocation *invocation = [self invocation];
    invocation.target = self;
    [invocation invoke];
}

+ (NSArray *)testInvocations {
    return objc_getAssociatedObject(self, &CDRXTestInvocationsKey);
}

+ (void)setTestInvocations:(NSArray *)array {
    objc_setAssociatedObject(self, &CDRXTestInvocationsKey, array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/// This is needed to allow for runtime lookup of the superclass
#define super_recordFailure(description, filename, lineNumber, expected) do { \
Class parentClass = class_getSuperclass([self class]); \
IMP superPerformTest = class_getMethodImplementation(parentClass, @selector(recordFailureWithDescription:inFile:atLine:expected:)); \
((void (*)(id instance, SEL cmd, NSString *, NSString *, NSUInteger, BOOL))superPerformTest)(self, _cmd, description, filename, lineNumber, expected); \
} while(0);

- (void)recordFailureWithDescription:(NSString *)description inFile:(NSString *)filename atLine:(NSUInteger)lineNumber expected:(BOOL)expected {
    CDRExample *example = self.invocation.cdr_examples.firstObject;
    if (example.state == CDRExampleStateIncomplete) {
        [[CDRSpecFailure specFailureWithReason:description fileName:filename lineNumber:(int)lineNumber] raise];
    } else {
        super_recordFailure(description, filename, lineNumber, expected);
    }
}

@end
