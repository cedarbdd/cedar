#import "SpecHelper.h"
#import "CDRExampleStateMap.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(CDRExampleStateMapSpec)

__block CDRExampleStateMap *map;

beforeEach(^{
    map = [CDRExampleStateMap stateMap];
});

describe(@"descriptionForState", ^{
    describe(@"for an incomplete state", ^{
        it(@"should return RUNNING", ^{
            NSString *descriptionForState = [map descriptionForState:CDRExampleStateIncomplete];
            expect(descriptionForState).to(equal(@"RUNNING"));
        });
    });

    describe(@"for a passed state", ^{
        it(@"should return PASSED", ^{
            NSString *descriptionForState = [map descriptionForState:CDRExampleStatePassed];
            expect(descriptionForState).to(equal(@"PASSED"));
        });
    });

    describe(@"for a pending state", ^{
        it(@"should return PENDING", ^{
            NSString *descriptionForState = [map descriptionForState:CDRExampleStatePending];
            expect(descriptionForState).to(equal(@"PENDING"));
        });
    });

    describe(@"for a skipped state", ^{
        it(@"should return SKIPPED", ^{
            NSString *descriptionForState = [map descriptionForState:CDRExampleStateSkipped];
            expect(descriptionForState).to(equal(@"SKIPPED"));
        });
    });

    describe(@"for a failed state", ^{
        it(@"should return FAILED", ^{
            NSString *descriptionForState = [map descriptionForState:CDRExampleStateFailed];
            expect(descriptionForState).to(equal(@"FAILED"));
        });
    });

    describe(@"for a error state", ^{
        it(@"should return ERROR", ^{
            NSString *descriptionForState = [map descriptionForState:CDRExampleStateError];
            expect(descriptionForState).to(equal(@"ERROR"));
        });
    });
});

SPEC_END

