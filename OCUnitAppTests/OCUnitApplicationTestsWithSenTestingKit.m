#define SENTEST_IGNORE_DEPRECATION_WARNING
#import <SenTestingKit/SenTestingKit.h>
#import "OCUnitAppAppDelegate.h" // should NOT be included in OCUnitAppTests target
#import "CDRXTestSuite.h"

@interface ExampleApplicationTestsWithSenTestingKit : SenTestCase
@end

@implementation ExampleApplicationTestsWithSenTestingKit
- (void)testApplicationTestsRun {
    UILabel *label = [[[UILabel alloc] init] autorelease];
    STAssertEquals([label class], [UILabel class], @"expected an instance of UILabel to be UILabel kind");
}

- (void)testHasAccessToClassesDefinedInApp {
    // For that to work app target must have 'Strip Debug Symbols During Copy' set to NO.
    STAssertEquals([OCUnitAppAppDelegate class], [OCUnitAppAppDelegate class], @"expected OCUnitAppAppDelegate class to equal itself");
}

- (void)testMainBundleIsTheAppBundle {
    STAssertTrue([[NSBundle mainBundle].bundlePath hasSuffix:@".app"], @"expected main NSBundle path to have 'app' extension");
}

- (void)testCanLoadNibFilesFromApp {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"DummyView" owner:nil options:nil];
    STAssertEquals([[views lastObject] class], [UIView class], @"expected last view of DummyView nib to be UIView kind");
}

- (void)testRunningCedarExamples {
    SenTestSuite *defaultSuite = [SenTestSuite defaultTestSuite];
    STAssertTrue([[defaultSuite valueForKeyPath:@"tests.name"] containsObject:@"Cedar"], @"should contain a Cedar test suite");
}

- (void)testCallingDefaultTestSuiteMultipleTimesShouldHaveDifferentReporters {
    SenTestSuite *defaultSuite1 = [SenTestSuite defaultTestSuite];
    SenTestSuite *defaultSuite2 = [SenTestSuite defaultTestSuite];

    CDRXTestSuite *suite1 = [[defaultSuite1 valueForKey:@"tests"] lastObject];
    CDRXTestSuite *suite2 = [[defaultSuite2 valueForKey:@"tests"] lastObject];
    STAssertTrue(suite1.dispatcher != suite2.dispatcher, @"Each test suite should have its own dispatcher");
}
@end
