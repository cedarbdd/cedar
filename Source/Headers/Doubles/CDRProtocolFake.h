#import <Foundation/Foundation.h>
#import "CedarDouble.h"
#import "CDRFake.h"

#import <sstream>
#import <string>

@interface CDRProtocolFake : CDRFake

- (id)initWithClass:(Class)klass forProtocol:(Protocol *)protocol requireExplicitStubs:(BOOL)requireExplicitStubs;

@end

id CDR_fake_for(Protocol *protocol, BOOL require_explicit_stubs = YES);
