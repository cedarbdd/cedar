#import "Cedar.h"

NSMutableArray *calledInFocusedSpec2__ = nil;
NSMutableArray *expectedCallsInFocusedSpec2__ = nil;

SPEC_BEGIN(FocusedSpec2)

calledInFocusedSpec2__ = [[NSMutableArray alloc] init];
expectedCallsInFocusedSpec2__ = [[NSMutableArray alloc] initWithObjects:@"fit", nil];

it(@"should not run non-focused example", ^{
    [calledInFocusedSpec2__ addObject:@"it"];
});

fit(@"should run focused example", ^{
    [calledInFocusedSpec2__ addObject:@"fit"];
});

SPEC_END
