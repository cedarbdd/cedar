#import "CDRSpec.h"
#import "CDRSharedExampleGroupPool.h"
#import "CDRExampleParent.h"

@interface SpecHelper : NSObject
{
    NSMutableDictionary *sharedExampleGroups_, *sharedExampleContext_;
}

@property (nonatomic, retain, readonly) NSMutableDictionary *sharedExampleContext;

+ (SpecHelper *)specHelper;

- (void)setUp;
- (void)tearDown;

- (void)beforeEach;
- (void)afterEach;

@end
