#import <Foundation/Foundation.h>

@protocol CDRStateTracking <NSObject>

- (void)didStartPreparingTests;
- (void)didStartRunningTests;
- (void)didFinishRunningTests;

@end
