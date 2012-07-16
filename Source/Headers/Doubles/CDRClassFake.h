#import <Foundation/Foundation.h>
#import "CDRFake.h"
#import "CedarDouble.h"

@interface CDRClassFake : CDRFake

@end

inline id CDR_fake_for(Class klass, bool require_explicit_stubs = true) {
    return [[[CDRClassFake alloc] initWithClass:klass requireExplicitStubs:require_explicit_stubs] autorelease];
}
