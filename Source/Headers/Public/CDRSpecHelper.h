#import "CDRSpec.h"
#import "CDRNullabilityCompat.h"
#import "CDRHooks.h"
#import "CDRSharedExampleGroupPool.h"
#import "CDRExampleParent.h"

#ifndef NS_SWIFT_NAME
#define NS_SWIFT_NAME(_name)
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CDRSpecHelper : NSObject <CDRExampleParent> {
    NSMutableDictionary *sharedExampleContext_, *sharedExampleGroups_;
    NSArray *globalBeforeEachClasses_, *globalAfterEachClasses_;
    BOOL shouldOnlyRunFocused_;
}

@property (nonatomic, retain, readonly) NSMutableDictionary *sharedExampleContext;
@property (nonatomic, retain) NSArray *globalBeforeEachClasses, *globalAfterEachClasses;

@property (nonatomic, assign) BOOL shouldOnlyRunFocused;

+ (CDRSpecHelper *)specHelper NS_SWIFT_NAME(specHelper());

@end

@compatibility_alias SpecHelper CDRSpecHelper;

NS_ASSUME_NONNULL_END

// This import is here for backwards-compatibility.
// The Cedar spec template used to only import CDRSpecHelper.h
#import "Cedar.h"
