#import "CDRSpec.h"
#import "CDRSharedExampleGroupPool.h"
#import "CDRExampleParent.h"

@interface SpecHelper : NSObject <CDRExampleParent> {
    NSMutableDictionary *sharedExampleContext_, *sharedExampleGroups_;
    NSArray *globalBeforeEachClasses_, *globalAfterEachClasses_;
}

@property (nonatomic, retain, readonly) NSMutableDictionary *sharedExampleContext;
@property (nonatomic, retain) NSArray *globalBeforeEachClasses, *globalAfterEachClasses;

+ (SpecHelper *)specHelper;

// Rather than defining global beforeEach/afterEach on the SpecHelper instance, simply declare a
// +beforeEach and/or +afterEach on a separate spec-specific class.  This allows for more than one
// beforeEach/afterEach without them overwriting one another.
- (void)beforeEach /*__attribute__((deprecated))*/;
- (void)afterEach /*__attribute__((deprecated))*/;

@end
