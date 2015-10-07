#import <Foundation/Foundation.h>

// This file redeclares various XCTest classes and selectors to make the compiler happy.

@class XCTestSuite;
@protocol XCTestObservation
@optional
- (void)testSuiteWillStart:(XCTestSuite *)testSuite;
@end


@interface CDRXCTestSupport

// XCTest

- (void)addTest:(id)test;
- (void)performTest:(id)aRun;

// XCTestSuite

- (id)allTests;
- (id)CDR_original_allTests;
- (id)initWithName:(NSString *)aName;

// XCTestObservationCenter
+ (instancetype)sharedTestObservationCenter;
- (void)addTestObserver:(id<XCTestObservation>)observer;

@end
