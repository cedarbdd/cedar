#import "CDRSpec.h"
#import "CDRHooks.h"
#import "CDRSharedExampleGroupPool.h"
#import "CDRExampleParent.h"

@interface CDRSpecHelper : NSObject <CDRExampleParent> {
    NSMutableDictionary *sharedExampleContext_, *sharedExampleGroups_;
    NSArray *globalBeforeEachClasses_, *globalAfterEachClasses_;
    BOOL shouldOnlyRunFocused_;
}

@property (nonatomic, retain, readonly) NSMutableDictionary *sharedExampleContext;
@property (nonatomic, retain) NSArray *globalBeforeEachClasses, *globalAfterEachClasses;

@property (nonatomic, assign) BOOL shouldOnlyRunFocused;

+ (CDRSpecHelper *)specHelper;

@end

@compatibility_alias SpecHelper CDRSpecHelper;
