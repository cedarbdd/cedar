#import <Foundation/Foundation.h>
#import "CDRExampleBase.h"

@protocol CDRExampleReporter;
@class CDRExampleGroup;

@protocol CDRSpec
@end

extern CDRSpecBlock PENDING;

#ifdef __cplusplus
extern "C" {
#endif
void describe(NSString *text, CDRSpecBlock block);
void beforeEach(CDRSpecBlock block);
void afterEach(CDRSpecBlock block);
void it(NSString *text, CDRSpecBlock block);
void fail(NSString *reason);
#ifdef __cplusplus
}
#endif

@interface CDRSpec : NSObject <CDRSpec> {
  CDRExampleGroup *rootGroup_;
  CDRExampleGroup *currentGroup_;
}

@property (nonatomic, retain) CDRExampleGroup *currentGroup, *rootGroup;

- (void)declareBehaviors;
- (void)defineBehaviors;

@end
