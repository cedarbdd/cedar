#ifdef USE_XCTEST
#import <XCTest/XCTest.h>
#else
#define SENTEST_IGNORE_DEPRECATION_WARNING
#import <SenTestingKit/SenTestingKit.h>
#endif

#import "DummyModel.h" // should be included in OCUnitAppLogicTests target

@interface ExampleLogicTestsWithSenTestingKit : SenTestCase
@end

@implementation ExampleLogicTestsWithSenTestingKit
- (void)testLogicTestsRun {
    STAssertEquals([DummyModel class], [DummyModel class], @"expected DummyModel class to equal itself");
}
@end

