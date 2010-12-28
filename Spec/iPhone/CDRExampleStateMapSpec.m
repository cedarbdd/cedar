#define HC_SHORTHAND
#import "CDRSpec.h"
#import "CDRSharedExampleGroupPool.h"
#import "OCMock.h"
#import "OCHamcrest.h"
#import "CDRExampleStateMap.h"

DESCRIBE(CDRExampleStateMap) {
    __block CDRExampleStateMap *map;

    beforeEach(^{
        map = [CDRExampleStateMap stateMap];
    });

    describe(@"descriptionForState", ^{
        describe(@"for an incomplete state", ^{
            it(@"should return RUNNING", ^{
                assertThat([map descriptionForState:CDRExampleStateIncomplete], equalTo(@"RUNNING"));
            });
        });
        describe(@"for a passed state", ^{
            it(@"should return PASSED", ^{
                assertThat([map descriptionForState:CDRExampleStatePassed], equalTo(@"PASSED"));
            });
        });
        describe(@"for a pending state", ^{
            it(@"should return PENDING", ^{
                assertThat([map descriptionForState:CDRExampleStatePending], equalTo(@"PENDING"));
            });
        });
        describe(@"for a failed state", ^{
            it(@"should return FAILED", ^{
                assertThat([map descriptionForState:CDRExampleStateFailed], equalTo(@"FAILED"));
            });
        });
        describe(@"for a error state", ^{
            it(@"should return ERROR", ^{
                assertThat([map descriptionForState:CDRExampleStateError], equalTo(@"ERROR"));
            });
        });
    });
}
DESCRIBE_END

