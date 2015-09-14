#import <XCTest/XCTest.h>
#import "OCUnitAppAppDelegate.h" // should NOT be included in OCUnitAppTests target
#import "TestObservationHelper.h"

@interface ExampleApplicationTestsWithXCTest : XCTestCase
@end

@implementation ExampleApplicationTestsWithXCTest
- (void)testApplicationTestsRun {
    UILabel *label = [[[UILabel alloc] init] autorelease];
    XCTAssertEqual([label class], [UILabel class], @"expected an instance of UILabel to be UILabel kind");
}

- (void)testHasAccessToClassesDefinedInApp {
    // For that to work app target must have 'Strip Debug Symbols During Copy' set to NO.
    XCTAssertEqual([OCUnitAppAppDelegate class], [OCUnitAppAppDelegate class], @"expected OCUnitAppAppDelegate class to equal itself");
}

- (void)testMainBundleIsTheAppBundle {
    XCTAssertTrue([[NSBundle mainBundle].bundlePath hasSuffix:@".app"], @"expected main NSBundle path to have 'app' extension");
}

- (void)testCanLoadNibFilesFromApp {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"DummyView" owner:nil options:nil];
    XCTAssertEqual([[views lastObject] class], [UIView class], @"expected last view of DummyView nib to be UIView kind");
}

- (void)testRunningCedarExamples {
    NSArray *knownTestSuites = [TestObservationHelper knownTestSuites];
    XCTAssert([[knownTestSuites valueForKeyPath:@"@unionOfArrays.tests.name"] containsObject:@"Cedar"]);
}

@end
