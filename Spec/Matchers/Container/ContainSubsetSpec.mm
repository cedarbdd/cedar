#import "Cedar.h"
#import "ExpectFailureWithMessage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ContainSubsetSpec)

describe(@"contain_subset matcher", ^{
    context(@"when the container is a dictionary", ^{
        NSDictionary *container = @{@"key": @"value",
                                    @"source": @"sink"};
        __block id subset;

        describe(@"positive matches", ^{
            beforeEach(^{
                subset = @{@"key": @"value",
                           @"source": @"sink"};
            });

            it(@"should contain itself as a subset", ^{
                expect(container).to(contain_subset(subset));
            });
        });

        describe(@"negative matches", ^{
            context(@"when the key and value are not present at all", ^{
                beforeEach(^{
                    subset = @{@"noway": @"josé"};
                });

                it(@"should not match", ^{
                    container should_not contain_subset(subset);
                });

                it(@"should provide a nicely formatted message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to contain subset <%@>", container, subset], ^{
                        container should contain_subset(subset);
                    });
                });
            });

            context(@"when the values exist but belong to different keys", ^{
                beforeEach(^{
                    subset = @{@"key": @"sink"};
                });

                it(@"should not match", ^{
                    container should_not contain_subset(subset);
                });

                it(@"should provide a nicely formatted message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to contain subset <%@>", container, subset], ^{
                        container should contain_subset(subset);
                    });
                });
            });
        });
    });

    context(@"when the container is not a dictionary but is an Obj-C object", ^{
        NSArray *weirdContainer = @[@"item1", @"item2"];
        id subset = nil;

        it(@"should not match", ^{
            expectExceptionWithReason(@"Unexpected use of the 'contain_subset' matcher with non-dictionary container <(\n    item1,\n    item2\n)>", ^{
                weirdContainer should_not contain_subset(subset);
            });
        });
    });

    context(@"when the container is not an Obj-C object", ^{
        char *notAnObjCObject = (char *)"whoops i accidentally all the tests";
        id subset = nil;

        it(@"should not match", ^{
            expectExceptionWithReason(@"Unexpected use of the 'contain_subset' matcher with non-dictionary container <cstring(whoops i accidentally all the tests)>", ^{
                notAnObjCObject should_not contain_subset(subset);
            });
        });
    });

    context(@"when the subset is not a dictionary but is an Obj-C object", ^{
        NSDictionary *container = @{};
        NSString *subset = @"whoops!";

        it(@"should not match", ^{
            expectExceptionWithReason(@"Unexpected use of the 'contain_subset' matcher with non-dictionary subset <whoops!>", ^{
                container should_not contain_subset(subset);
            });
        });
    });

    context(@"when the subset is not an Obj-C object", ^{
        NSDictionary *container = @{};
        char *notAnObject = (char *)"whoops!";

        it(@"should not match", ^{
            expectExceptionWithReason(@"Unexpected use of the 'contain_subset' matcher with non-dictionary subset <cstring(whoops!)>", ^{
                container should_not contain_subset(notAnObject);
            });
        });
    });
});

SPEC_END
