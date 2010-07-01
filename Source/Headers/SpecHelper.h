#import "CDRSpec.h"
#import "CDRSharedExampleGroupPool.h"
#import "CDRExampleParent.h"

@interface SpecHelper : NSObject <CDRExampleParent> {
    NSMutableDictionary *sharedExampleGroups_;
}

+ (id)specHelper;

- (void)beforeEach;
- (void)afterEach;

@end
