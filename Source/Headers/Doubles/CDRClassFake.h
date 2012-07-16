#import <Foundation/Foundation.h>
#import "CedarDouble.h"

@interface CDRClassFake : NSObject<CedarDouble>

@property (nonatomic, assign) bool require_explicit_stubs;

- (id)initWithClass:(Class)klass;

@end

inline id CDR_fake_for(Class klass) {
    return [[[CDRClassFake alloc] initWithClass:klass] autorelease];
}

inline id CDR_nice_fake_for(Class klass) {
    CDRClassFake * fake = CDR_fake_for(klass);
    fake.require_explicit_stubs = false;
    return fake;
}

#ifndef CEDAR_DOUBLES_COMPATIBILITY_MODE
#define fake_for(x) CDR_fake_for((x))
#define nice_fake_for(x) CDR_nice_fake_for((x))
#endif
