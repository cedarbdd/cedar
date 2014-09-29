#define SENTEST_IGNORE_DEPRECATION_WARNING
#import <SenTestingKit/SenTestingKit.h>
#import "OCUnitAppAppDelegate.h" // should NOT be included in OCUnitAppTests target
#import "CDRXTestSuite.h"
#import "Cedar.h"

using namespace Cedar::Matchers;

static BOOL shouldFail = NO;

#pragma mark - TestObserver
@interface CDRSenTestObserver : SenTestCaseRun
@property (retain, nonatomic) NSException *lastException;
@end

@implementation CDRSenTestObserver

- (void)dealloc {
    self.lastException = nil;
    [super dealloc];
}

- (void)addException:(NSException *)anException {
    self.lastException = anException;
}

- (void)postNotificationName:(NSString *)aNotification userInfo:(NSDictionary *)aUserInfo {}
- (void)postNotificationName:(NSString *)aNotification {}

@end

#pragma mark - SenTestingKit specs
@interface ExampleApplicationTestsWithSenTestingKit : SenTestCase
@end

@implementation ExampleApplicationTestsWithSenTestingKit

- (void)tearDown {
    shouldFail = NO;
}

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

- (void)testFailingInATestSuiteProperlyRaisesASenTestingKitException {
    CDRXTestSuite *suite = [[[SenTestSuite defaultTestSuite] valueForKey:@"tests"] lastObject];
    NSInteger index = [[suite valueForKeyPath:@"tests.name"] indexOfObject:@"SimulatedTestSuiteFailureSpec"];
    STAssertTrue(index != NSNotFound, @"Failed to find the SimulatedTestSuiteFailureSpec");

    CDRSenTestObserver *observer = [[[CDRSenTestObserver alloc] init] autorelease];

    shouldFail = YES;
    SenTestCase *testCase = [[[[suite valueForKeyPath:@"tests"] objectAtIndex:index] valueForKey:@"tests"] objectAtIndex:0];
    [testCase performTest:observer];

    STAssertNotNil(observer.lastException, @"Expected exception to be thrown");
    STAssertEqualObjects(observer.lastException.name, SenTestFailureException, @"Expected %@, but got %@", SenTestFailureException, observer.lastException.name);
    NSString *expectedFilename = [NSString stringWithUTF8String:__FILE__];
    STAssertEqualObjects([observer.lastException filename], expectedFilename, @"Expected %@, but got %@", expectedFilename, [observer.lastException filename]);
}

@end

#pragma mark - failing cedar spec

SPEC_BEGIN(SimulatedTestSuiteFailureSpec)

describe(@"SimulatedTestSuiteFailureSpec", ^{
    it(@"should fail when told to", ^{
        if (shouldFail) {
            1 should equal(2);
        }
    });
});

SPEC_END
