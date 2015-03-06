#import <Foundation/Foundation.h>
#import "CDRProtocolFake.h"

@interface CDRClassProtocolFake : CDRProtocolFake

- (instancetype)initWithClass:(Class)baseClass fakedClass:(Class)fakedClass forProtocols:(NSArray *)protocolArray requireExplicitStubs:(BOOL)require_explicit_stubs;

@end

id CDR_fake_for(BOOL require_explicit_stubs, Class fakedClass, ...);
