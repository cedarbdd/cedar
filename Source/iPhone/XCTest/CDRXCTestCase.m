#import "CDRXCTestCase.h"
#import <objc/runtime.h>

const char *CDRXSeedKey;
const char *CDRXTestInvocationsKey;
const char *CDRXSpecKey;
const char *CDRXDispatcherKey;
const char *CDRXExampleKey;
const char *CDRXSpecClassNameKey;

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
    return objc_getAssociatedObject([self invocation], &CDRXSpecClassNameKey);
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

@end
