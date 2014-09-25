#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

@interface OS_X_Host_AppTests : XCTestCase

@end

@implementation OS_X_Host_AppTests

- (void)testMainBundleIsTheAppBundle {
    XCTAssertTrue([[NSBundle mainBundle].bundlePath hasSuffix:@".app"], @"expected main NSBundle path to have 'app' extension");
}

- (void)testRunningCedarExamples {
    XCTestSuite *defaultSuite = [XCTestSuite defaultTestSuite];
    XCTAssert([[defaultSuite valueForKeyPath:@"tests.name"] containsObject:@"Cedar"]);
}
@end
