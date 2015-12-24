#import <Foundation/Foundation.h>
#import "CedarDouble.h"
#import "CDRFake.h"

#ifdef __cplusplus

#import <sstream>
#import <string>

@interface CDRProtocolFake : CDRFake

- (id)initWithClass:(Class)klass forProtocols:(NSArray *)protocols requireExplicitStubs:(BOOL)requireExplicitStubs;

@end

id CDR_fake_for(BOOL require_explicit_stubs, Protocol *protocol, ...);

#endif // __cplusplus
