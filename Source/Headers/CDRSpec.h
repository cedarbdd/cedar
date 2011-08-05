#import <Foundation/Foundation.h>
#import "CDRExampleBase.h"

@protocol CDRExampleReporter;
@class CDRExampleGroup, SpecHelper;

@protocol CDRSpec
@end

extern CDRSpecBlock PENDING;

#ifdef __cplusplus
extern "C" {
#endif
void describe(NSString *, CDRSpecBlock);
void beforeEach(CDRSpecBlock);
void afterEach(CDRSpecBlock);
void it(NSString *, CDRSpecBlock);
void fail(NSString *);
void context(NSString *, CDRSpecBlock);
void xcontext(NSString *, CDRSpecBlock);
void xdescribe(NSString *, CDRSpecBlock);
void xit(NSString *, CDRSpecBlock);
#ifdef __cplusplus
}

#import "ActualValue.h"
#import "CedarComparators.h"
#ifdef CEDAR_CUSTOM_COMPARATORS
#import CEDAR_CUSTOM_COMPARATORS
#endif
#import "CedarMatchers.h"
#ifdef CEDAR_CUSTOM_MATCHERS
#import CEDAR_CUSTOM_MATCHERS
#endif

#endif // __cplusplus

@interface CDRSpec : NSObject <CDRSpec> {
  CDRExampleGroup *rootGroup_;
  CDRExampleGroup *currentGroup_;
}

@property (nonatomic, retain) CDRExampleGroup *currentGroup, *rootGroup;
- (void)defineBehaviors;
@end

@interface CDRSpec (SpecDeclaration)
- (void)declareBehaviors;
@end

#define SPEC_BEGIN(name)             \
@interface name : CDRSpec            \
@end                                 \
@implementation name                 \
- (void)declareBehaviors {

#define SPEC_END                     \
}                                    \
@end
