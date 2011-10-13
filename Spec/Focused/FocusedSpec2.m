#if TARGET_OS_IPHONE
// Normally you would include this file out of the framework.  However, we're
// testing the framework here, so including the file from the framework will
// conflict with the compiler attempting to include the file from the project.
#import "SpecHelper.h"
#import "OCMock.h"
#else
#import <Cedar/SpecHelper.h>
#import <OCMock/OCMock.h>
#endif

NSMutableArray *calledInFocusedSpec2__ = nil;
NSMutableArray *expectedCallsInFocusedSpec2__ = nil;

SPEC_BEGIN(FocusedSpec2)

calledInFocusedSpec2__ = [[NSMutableArray alloc] init];
expectedCallsInFocusedSpec2__ = [[NSArray alloc] initWithObjects:@"fit", nil];

it(@"should not run non-focused example", ^{
    [calledInFocusedSpec2__ addObject:@"it"];
});

fit(@"should run focused example", ^{
    [calledInFocusedSpec2__ addObject:@"fit"];
});

SPEC_END
