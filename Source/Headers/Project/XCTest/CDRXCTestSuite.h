#import <Foundation/Foundation.h>

@class CDRReportDispatcher;

/// This class should be thought of as a XCTestSuite subclass. The methods on this class are
/// copied onto a true XCTestSuite subclass created dynamically at runtime, allowing Cedar
/// to not need to link with XCTest
@interface CDRXCTestSuite : NSObject

- (void)setDispatcher:(CDRReportDispatcher *)dispatcher;
- (CDRReportDispatcher *)dispatcher;

@end
