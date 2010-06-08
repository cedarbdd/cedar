#import <Cedar/SpecHelper.h>
#import "CDRExampleGroup.h"
#import "CDRExample.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

SPEC_BEGIN(CDRExampleGroupSpec)

describe(@"CDRExampleGroup", ^{
    __block CDRExampleGroup *group;

    beforeEach(^{
        group = [[CDRExampleGroup alloc] initWithText:@"a group"];
    });

    afterEach(^{
        [group release];
    });

    describe(@"state", ^{
        describe(@"for a group containing no examples", ^{
            beforeEach(^{
                assertThatInt([[group examples] count], equalToInt(0));
            });

            it(@"should be CDRExampleStatePassed", ^{
                assertThatInt([group state], equalToInt(CDRExampleStatePassed));
            });
        });

        describe(@"for a group containing at least one incomplete example", ^{
            beforeEach(^{
                CDRExample *incompleteExample = [[CDRExample alloc] initWithText:@"incomplete" andBlock:^{}];
                [group add:incompleteExample];
                [incompleteExample release];
            });

            it(@"should be CDRExampleStateIncomplete", ^{
                assertThatInt([group state], equalToInt(CDRExampleStateIncomplete));
            });
        });

        describe(@"for a group containing only complete examples", ^{
            describe(@"with only passing examples", ^{
                it(@"should be CDRExampleStatePassed", PENDING);
            });

            describe(@"with only failing examples", ^{
                it(@"should be CDRExampleStateFailed", PENDING);
            });

            describe(@"with only pending examples", ^{
                it(@"should be CDRExampleStatePending", PENDING);
            });

            describe(@"with only error examples", ^{
                it(@"should be CDRExampleStateError", PENDING);
            });

            describe(@"with at least one failing example", ^{
                describe(@"with all other examples passing", ^{
                    it(@"should be CDRExampleStateFailed", PENDING);
                });

                describe(@"with at least one pending example", ^{
                    it(@"should be CDRExampleStateFailed", PENDING);
                });
            });

            describe(@"with at least one error example", ^{
                describe(@"with all other examples passing", ^{
                    it(@"should be CDRExampleStateError", PENDING);
                });

                describe(@"with at least one failing example", ^{
                    it(@"should be CDRExampleStateError", PENDING);
                });

                describe(@"with at least one pending example", ^{
                    it(@"should be CDRExampleStateError", PENDING);
                });
            });

            describe(@"with at least one pending example", ^{
                describe(@"with all other examples passing", ^{
                    it(@"should be CDRExampleStatePending", PENDING);
                });
            });
        });
    });

    describe(@"progress", ^{
        // !!!
    });
});

SPEC_END
