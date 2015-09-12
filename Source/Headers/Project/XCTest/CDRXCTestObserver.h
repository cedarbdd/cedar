#import <Foundation/Foundation.h>

@class XCTestSuite;
@protocol XCTestObservation
@optional
- (void)testBundleDidFinish:(NSBundle *)testBundle;
@end

@interface XCTestObservationCenter
+ (instancetype)sharedTestObservationCenter;
- (void)addTestObserver:(id<XCTestObservation>)observer;
@end

@interface CDRXCTestObserver : NSObject <XCTestObservation>
@end
