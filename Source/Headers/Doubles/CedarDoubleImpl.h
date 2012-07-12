#import <Foundation/Foundation.h>
#import "StubbedMethod.h"

@protocol CedarDouble;

namespace Cedar { namespace Doubles {
    class StubbedMethodPrototype;
}}

@interface CedarDoubleImpl : NSObject

@property (nonatomic, retain, readonly) NSMutableArray *sent_messages;

- (id)initWithDouble:(id<CedarDouble>)parent_double;

- (Cedar::Doubles::StubbedMethodPrototype &)stubbed_method_prototype;
- (Cedar::Doubles::StubbedMethod::selector_map_t &)stubbed_methods;
- (Cedar::Doubles::StubbedMethod &)create_stubbed_method_for:(SEL)selector;
- (BOOL)invoke_stubbed_method:(NSInvocation *)invocation;
- (void)record_method_invocation:(NSInvocation *)invocation;

@end
