#import <XCTest/XCTest.h>
#import "TestObservationHelper.h"

@interface ExampleApplicationTestsWithXCTest : XCTestCase
@end

@implementation ExampleApplicationTestsWithXCTest

- (void)testMainBundleIsTheAppBundle {
    XCTAssertTrue([[NSBundle mainBundle].bundlePath hasSuffix:@".app"], @"expected main NSBundle path to have 'app' extension");
}

- (void)testRunningCedarExamples {
    NSArray *knownTestSuites = [TestObservationHelper knownTestSuites];
    XCTAssert([[knownTestSuites valueForKeyPath:@"@unionOfArrays.tests.name"] containsObject:@"Cedar"]);
}

@end
