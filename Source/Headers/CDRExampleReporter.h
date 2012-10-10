#import <Foundation/Foundation.h>

@protocol CDRExampleReporter <NSObject>

- (void)runWillStartWithGroups:(NSArray *)groups andRandomSeed:(unsigned int)seed;
- (void)runDidComplete;
- (int)result;

@end
