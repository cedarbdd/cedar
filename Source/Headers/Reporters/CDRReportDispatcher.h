#import "CDRExampleReporter.h"

@class CDRExampleGroup, CDRExample, CDRSpec;

@interface CDRReportDispatcher : NSObject {
    NSArray *reporters_;
}

+ (instancetype)dispatcherWithReporters:(NSArray *)reporters;
- (id)initWithReporters:(NSArray *)reporters;

- (void)runWillStartWithGroups:(NSArray *)groups andRandomSeed:(unsigned int)seed;

- (void)runDidComplete;
- (int)result;

- (void)runWillStartExampleGroup:(CDRExampleGroup *)exampleGroup;
- (void)runDidFinishExampleGroup:(CDRExampleGroup *)exampleGroup;

- (void)runWillStartExample:(CDRExample *)example;
- (void)runDidFinishExample:(CDRExample *)example;

@end
