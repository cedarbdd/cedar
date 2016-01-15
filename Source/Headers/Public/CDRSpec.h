#import <Foundation/Foundation.h>
#import "CDRExampleBase.h"
#import "CDRNullabilityCompat.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CDRExampleReporter;
@class CDRExampleGroup, CDRExample, CDRSpecHelper, CDRSymbolicator;
@class CDRReportDispatcher;

@protocol CDRSpec
@end

extern const __nullable CDRSpecBlock PENDING;

#ifdef __cplusplus
extern "C" {
#endif
void beforeEach(CDRSpecBlock);
void afterEach(CDRSpecBlock);

CDRExampleGroup * describe(NSString *, __nullable CDRSpecBlock);
extern CDRExampleGroup* __nonnull (*__nonnull context)(NSString *, __nullable CDRSpecBlock);

CDRExample * it(NSString *, __nullable CDRSpecBlock);

CDRExampleGroup * xdescribe(NSString *, __nullable CDRSpecBlock);
extern CDRExampleGroup* __nonnull (*__nonnull xcontext)(NSString *, __nullable CDRSpecBlock);
void subjectAction(CDRSpecBlock);
CDRExample * xit(NSString *, __nullable CDRSpecBlock);

CDRExampleGroup * fdescribe(NSString *, __nullable CDRSpecBlock);
extern CDRExampleGroup* __nonnull (*__nonnull fcontext)(NSString *, __nullable CDRSpecBlock);
CDRExample * fit(NSString *, __nullable CDRSpecBlock);

void fail(NSString *);
#ifdef __cplusplus
}
#endif

@interface CDRSpec : NSObject <CDRSpec> {
    CDRExampleGroup *rootGroup_;
    CDRExampleGroup *currentGroup_;
    NSString *fileName_;
    CDRSymbolicator *symbolicator_;
}

@property (nonatomic, retain) CDRExampleGroup *currentGroup, *rootGroup;
@property (nonatomic, retain, nullable) NSString *fileName;
@property (nonatomic, retain) CDRSymbolicator *symbolicator;

- (void)defineBehaviors;
- (void)markAsFocusedClosestToLineNumber:(NSUInteger)lineNumber;
- (NSArray *)allChildren;
@end

@interface CDRSpec (XCTestSupport)
- (id)testSuiteWithRandomSeed:(unsigned int)seed dispatcher:(CDRReportDispatcher *)dispatcher;
@end

@interface CDRSpec (SpecDeclaration)
- (void)declareBehaviors;
@end

#define SPEC_BEGIN(name)             \
@interface name : CDRSpec            \
@end                                 \
@implementation name                 \
- (void)declareBehaviors {           \
    self.fileName = [NSString stringWithUTF8String:__FILE__];

#define SPEC_END                     \
}                                    \
@end

NS_ASSUME_NONNULL_END
