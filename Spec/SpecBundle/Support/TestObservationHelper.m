#import "TestObservationHelper.h"
#import "CDRXCTestSupport.h"

@interface XCTestSuite
+ (instancetype)defaultTestSuite;
@end

@interface TestObservationHelper () <XCTestObservation> @end

// This class is loaded as the NSPrincipalClass of test bundles that require it, at which point
// it registers itself as a test observer.
@implementation TestObservationHelper

static NSMutableArray *_knownTestSuites;

- (instancetype)init {
    if (self = [super init]) {
        Class observationCenterClass = NSClassFromString(@"XCTestObservationCenter");
        if (observationCenterClass && [observationCenterClass respondsToSelector:@selector(sharedTestObservationCenter)]) {
            _knownTestSuites = [NSMutableArray array];
            [[observationCenterClass sharedTestObservationCenter] addTestObserver:self];
        }
    }
    return self;
}

+ (NSArray *)knownTestSuites {
    return [_knownTestSuites copy] ?: @[[XCTestSuite defaultTestSuite]];
}

- (void)testSuiteWillStart:(XCTestSuite *)suite {
    [_knownTestSuites addObject:suite];
}

@end
