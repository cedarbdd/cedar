#import <Cedar/Cedar.h>

extern NSMutableArray *calledInFocusedSpec__;
extern NSMutableArray *expectedCallsInFocusedSpec__;

extern NSMutableArray *calledInFocusedSpec2__;
extern NSMutableArray *expectedCallsInFocusedSpec2__;

BOOL wereExpectedCallsMade(NSArray *actuallyCalled, NSArray *expectedCalls);

int main (int argc, const char *argv[]) {
    CDRRunSpecs();

    BOOL expectedCallsMade =
        wereExpectedCallsMade(calledInFocusedSpec__, expectedCallsInFocusedSpec__) &&
        wereExpectedCallsMade(calledInFocusedSpec2__, expectedCallsInFocusedSpec2__);

    [calledInFocusedSpec__ release];
    [expectedCallsInFocusedSpec__ release];

    [calledInFocusedSpec2__ release];
    [expectedCallsInFocusedSpec2__ release];

    return expectedCallsMade ? 0 : 1;
}

BOOL wereExpectedCallsMade(NSArray *callsMade, NSArray *expectedCalls) {
    BOOL expectedCallsMade = YES;

    for (NSString *callName in expectedCalls) {
        if (![callsMade containsObject:callName]) {
            NSLog(@"Example '%@' was not ran but should have been.", callName);
            expectedCallsMade = NO;
        }
    }

    if ([callsMade count] > [expectedCalls count]) {
        NSLog(@"Extra examples were ran but should not have been.");
        expectedCallsMade = NO;
    }

    return expectedCallsMade;
}
