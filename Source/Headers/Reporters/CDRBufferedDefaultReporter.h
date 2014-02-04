#import "CDRDefaultReporter.h"

@interface CDRBufferedDefaultReporter : CDRDefaultReporter
@property (retain, nonatomic) NSMutableString *buffer;

#pragma mark Overrides
- (void)runWillStartWithGroups:(NSArray *)groups andRandomSeed:(unsigned int)seed;
- (void)runDidComplete;
- (void)logText:(NSString *)linePartial;
@end
