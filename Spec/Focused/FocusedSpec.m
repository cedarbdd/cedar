#import "Cedar.h"

NSMutableArray *calledInFocusedSpec__ = nil;
NSMutableArray *expectedCallsInFocusedSpec__ = nil;

SPEC_BEGIN(FocusedSpec)

calledInFocusedSpec__ = [[NSMutableArray alloc] init];
expectedCallsInFocusedSpec__ =
    [[NSMutableArray alloc] initWithObjects:
        @"fit",
        @"describe-fit",
        @"describe-describe-fit",
        @"describe-fdescribe-it",
        @"describe-fdescribe-fit",
        @"fdescribe-it",
        @"fdescribe-fit",
        @"fdescribe-describe-it",
        @"fdescribe-describe-fit",
        @"fdescribe-fdescribe-it",
        @"fdescribe-fdescribe-fit",
        @"context-fit",
        @"fcontext-it",
        @"fcontext-fit",
        nil];

it(@"should not run non-focused example", ^{
    [calledInFocusedSpec__ addObject:@"it"];
});

fit(@"should run focused example", ^{
    [calledInFocusedSpec__ addObject:@"fit"];
});

describe(@"inside non-focused describe", ^{
    it(@"should not run non-focused example", ^{
        [calledInFocusedSpec__ addObject:@"describe-it"];
    });

    fit(@"should run focused example", ^{
        [calledInFocusedSpec__ addObject:@"describe-fit"];
    });

    describe(@"inside nested non-focused describe", ^{
        it(@"should not run non-focused example", ^{
            [calledInFocusedSpec__ addObject:@"describe-describe-it"];
        });

        fit(@"should run focused example", ^{
            [calledInFocusedSpec__ addObject:@"describe-describe-fit"];
        });
    });

    fdescribe(@"inside nested focused describe", ^{
        it(@"should run non-focused example", ^{
            [calledInFocusedSpec__ addObject:@"describe-fdescribe-it"];
        });

        fit(@"should run focused example", ^{
            [calledInFocusedSpec__ addObject:@"describe-fdescribe-fit"];
        });
    });
});

fdescribe(@"inside focused describe", ^{
    it(@"should run non-focused example", ^{
        [calledInFocusedSpec__ addObject:@"fdescribe-it"];
    });

    fit(@"should run focused example", ^{
        [calledInFocusedSpec__ addObject:@"fdescribe-fit"];
    });

    describe(@"inside nested non-focused describe", ^{
        it(@"should run non-focused example", ^{
            [calledInFocusedSpec__ addObject:@"fdescribe-describe-it"];
        });

        fit(@"should run focused example", ^{
            [calledInFocusedSpec__ addObject:@"fdescribe-describe-fit"];
        });
    });

    fdescribe(@"inside nested focused describe", ^{
        it(@"should run non-focused example", ^{
            [calledInFocusedSpec__ addObject:@"fdescribe-fdescribe-it"];
        });

        fit(@"should run focused example", ^{
            [calledInFocusedSpec__ addObject:@"fdescribe-fdescribe-fit"];
        });
    });
});

context(@"inside non-focused context", ^{
    it(@"should not run non-focused example", ^{
        [calledInFocusedSpec__ addObject:@"context-it"];
    });

    fit(@"should run focused example", ^{
        [calledInFocusedSpec__ addObject:@"context-fit"];
    });
});

fcontext(@"inside focused context", ^{
    it(@"should run non-focused example", ^{
        [calledInFocusedSpec__ addObject:@"fcontext-it"];
    });

    fit(@"should run focused example", ^{
        [calledInFocusedSpec__ addObject:@"fcontext-fit"];
    });
});

SPEC_END
