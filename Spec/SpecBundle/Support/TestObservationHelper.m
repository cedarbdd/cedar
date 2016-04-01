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

        // See comment in CDRXCTestFunctions.m for context on the dispatch_async
        dispatch_async(dispatch_get_main_queue(), ^{
            [[observationCenterClass sharedTestObservationCenter] addTestObserver:(id)[TestObservationHelper new]];
        });
    }
}

+ (NSArray *)knownTestSuites {
    return [_knownTestSuites copy] ?: @[[XCTestSuite defaultTestSuite]];
}

- (void)testSuiteWillStart:(XCTestSuite *)suite {
    [_knownTestSuites addObject:suite];
}

@end
