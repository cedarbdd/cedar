#import <Foundation/Foundation.h>
#import "CDRFake.h"
#import "CedarDouble.h"

#ifdef __cplusplus

@interface CDRClassFake : CDRFake

@end

id CDR_fake_for(BOOL require_explicit_stubs, Class klass, ...);

#endif // __cplusplus
