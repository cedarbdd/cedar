#import "CDRDefaultReporter.h"

@class CDRExample;

@interface CDRBufferedDefaultReporter : CDRDefaultReporter

#pragma mark Overrides
- (void)runWillStartWithGroups:(NSArray *)groups andRandomSeed:(unsigned int)seed;
- (void)printStats;
- (void)logText:(NSString *)linePartial;

@end
