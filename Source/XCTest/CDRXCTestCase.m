#import "CDRXCTestCase.h"
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

@end
