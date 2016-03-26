#import "CDRXCTestObserver.h"
#import "CDRFunctions.h"
#import "CDRPrivateFunctions.h"

@interface CDRXCTestObserver ()
@property (assign) BOOL observedTestSuiteStart;
@end

@implementation CDRXCTestObserver
- (instancetype)init {
    if (self = [super init]) {
        Class observationCenterClass = NSClassFromString(@"XCTestObservationCenter");
        if (observationCenterClass && [observationCenterClass respondsToSelector:@selector(sharedTestObservationCenter)]) {
            [[observationCenterClass sharedTestObservationCenter] addTestObserver:self];
        }
    }
    return self;
}
- (void)testSuiteWillStart:(XCTestSuite *)testSuite {
    if (self.observedTestSuiteStart) {
        return;
    }
    self.observedTestSuiteStart = YES;

    id cedarTestSuite = CDRCreateXCTestSuite();
    [testSuite addTest:cedarTestSuite];
}

@end
