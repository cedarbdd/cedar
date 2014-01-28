#import <Foundation/Foundation.h>
#import "CedarDouble.h"
#import "StubbedMethod.h"
#import "RejectedMethod.h"

typedef enum {
    CDRStubMethodNotStubbed = 0,
    CDRStubMethodInvoked,
    CDRStubWrongArguments,
} CDRStubInvokeStatus;

@interface CedarDoubleImpl : NSObject<CedarDouble>

+ (void)afterEach;

- (id)initWithDouble:(NSObject<CedarDouble> *)parent_double;

- (CDRStubInvokeStatus)invoke_stubbed_method:(NSInvocation *)invocation;
- (void)record_method_invocation:(NSInvocation *)invocation;

@end
