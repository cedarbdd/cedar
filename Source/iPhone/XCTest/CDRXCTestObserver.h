#import <Foundation/Foundation.h>

@class XCTestSuite;
@protocol XCTestObservation
- (void)testSuiteWillStart:(XCTestSuite *)testSuite;
@end

@class XCTestObservationCenter;
@interface XCTestObservationCenter
@end

@interface XCTestObservationCenter (CDRVisibility)
+ (instancetype)sharedTestObservationCenter;
- (void)addTestObserver:(id<XCTestObservation>)observer;
- (void)removeTestObserver:(id<XCTestObservation>)observer;
@end

@interface CDRXCTestObserver : NSObject <XCTestObservation>

@end
