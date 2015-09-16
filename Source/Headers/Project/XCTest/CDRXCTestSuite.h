#import <Foundation/Foundation.h>

@class CDRSpecRun;

/// This class should be thought of as a XCTestSuite subclass. The methods on this class are
/// copied onto a true XCTestSuite subclass created dynamically at runtime, allowing Cedar
/// to not need to link with XCTest
@interface CDRXCTestSuite : NSObject

- (instancetype)initWithSpecRun:(CDRSpecRun *)specRun;

@end
