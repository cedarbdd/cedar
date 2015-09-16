#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "TestObservationHelper.h"

@interface OS_X_Host_AppTests : XCTestCase
@end

@implementation OS_X_Host_AppTests

- (void)testMainBundleIsTheAppBundle {
    XCTAssertTrue([[NSBundle mainBundle].bundlePath hasSuffix:@".app"], @"expected main NSBundle path to have 'app' extension");
}

- (void)testRunningCedarExamples {
    NSArray *knownTestSuites = [TestObservationHelper knownTestSuites];
    XCTAssert([[knownTestSuites valueForKeyPath:@"@unionOfArrays.tests.name"] containsObject:@"Cedar"]);
}

@end
