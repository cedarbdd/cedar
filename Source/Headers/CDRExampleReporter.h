#import <Foundation/Foundation.h>

@protocol CDRExampleReporter <NSObject>

- (void)runWillStartWithGroups:(NSArray *)groups;
- (void)runDidComplete;
- (void)runDidComplete:(BOOL)printStats;
- (int)result;

@end
