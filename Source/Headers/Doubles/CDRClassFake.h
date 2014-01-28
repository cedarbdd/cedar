#import <Foundation/Foundation.h>
#import "CDRFake.h"
#import "CedarDouble.h"

@interface CDRClassFake : CDRFake

@end

id CDR_fake_for(BOOL require_explicit_stubs, Class klass, ...);
