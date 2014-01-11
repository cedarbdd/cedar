#import <Foundation/Foundation.h>
#import "CedarDouble.h"

@interface CDRFake : NSObject<CedarDouble>

@property (nonatomic, assign) Class klass;
@property (nonatomic, assign) BOOL requiresExplicitStubs;

- (id)initWithClass:(Class)klass requireExplicitStubs:(BOOL)requireExplicitStubs;

@end

#ifndef CEDAR_DOUBLES_COMPATIBILITY_MODE
#define fake_for(...) CDR_fake_for(YES, __VA_ARGS__, nil)
#define nice_fake_for(...) CDR_fake_for(NO, __VA_ARGS__, nil)
#endif
