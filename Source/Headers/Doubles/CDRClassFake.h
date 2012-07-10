#import <Foundation/Foundation.h>
#import "CedarDouble.h"

@interface CDRClassFake : NSObject<CedarDouble>

- (id)initWithClass:(Class)klass;

@end

inline id CDR_fake(Class klass) {
    return [[[CDRClassFake alloc] initWithClass:klass] autorelease];
}

#ifndef CEDAR_DOUBLES_COMPATIBILITY_MODE
#define fake(x) CDR_fake((x))
#endif
