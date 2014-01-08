#import <Foundation/Foundation.h>

@class CDRExample, CDRExampleGroup, CDRSpec;

@protocol CDRExampleReporter <NSObject>

- (void)runWillStartWithGroups:(NSArray *)groups andRandomSeed:(unsigned int)seed;
- (void)runDidComplete;
- (int)result;

// new methods to use instead of KVO
@optional
- (void)runWillStartExample:(CDRExample *)example;
- (void)runDidFinishExample:(CDRExample *)example;

- (void)runWillStartExampleGroup:(CDRExampleGroup *)exampleGroup;
- (void)runDidFinishExampleGroup:(CDRExampleGroup *)exampleGroup;

- (void)runWillStartSpec:(CDRSpec *)spec;
- (void)runDidFinishSpec:(CDRSpec *)spec;

@end
