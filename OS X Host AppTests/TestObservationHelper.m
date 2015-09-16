#import "TestObservationHelper.h"
#import "CDRXCTestSupport.h"

@interface XCTestSuite
+ (instancetype)defaultTestSuite;
@end

@interface TestObservationHelper () <XCTestObservation> @end

@implementation TestObservationHelper

static NSMutableArray *_knownTestSuites;

+ (void)load {
    Class observationCenterClass = NSClassFromString(@"XCTestObservationCenter");
    if (observationCenterClass && [observationCenterClass respondsToSelector:@selector(sharedTestObservationCenter)]) {
        _knownTestSuites = [NSMutableArray array];

        [[observationCenterClass sharedTestObservationCenter] addTestObserver:(id)[TestObservationHelper new]];
    }
}

+ (NSArray *)knownTestSuites {
    return [_knownTestSuites copy] ?: @[[XCTestSuite defaultTestSuite]];
}

- (void)testSuiteWillStart:(XCTestSuite *)suite {
    [_knownTestSuites addObject:suite];
}

@end
