#import <Cedar/Cedar.h>
#import "NSArray+ExplicitDescription.h"
#import "NSDictionary+ExplicitDescription.h"
#import "NSSet+ExplicitDescription.h"
#import "NSOrderedSet+ExplicitDescription.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CollectionsExplicitDescriptionSpec)

describe(@"Explicit Descriptions on Collection Types", ^{
    describe(@"NSArray", ^{
        NSArray *array = @[
                           @1,
                           @"two",
                           @[ @"three" ],
                           [NSSet setWithObject:@4],
                           @{ @"five": @6 },
                           [NSOrderedSet orderedSetWithObject:@"seven"]
                           ];

        it(@"should describe collections recursively, annotating non-collection types", ^{
            [array cdr_explicitDescription] should equal(@"(\n"
                                                         @"    1 (__NSCFNumber),\n"
                                                         @"    two (__NSCFConstantString),\n"
                                                         @"    (\n"
                                                         @"        three (__NSCFConstantString)\n"
                                                         @"    ),\n"
                                                         @"    {(\n"
                                                         @"        4 (__NSCFNumber)\n"
                                                         @"    )},\n"
                                                         @"    {\n"
                                                         @"        five (__NSCFConstantString) = 6 (__NSCFNumber)\n"
                                                         @"    },\n"
                                                         @"    {(\n"
                                                         @"        seven (__NSCFConstantString)\n"
                                                         @"    )}\n"
                                                         @")");
        });
    });

    describe(@"NSDictionary", ^{
        NSDictionary *dictionary = @{
                                     @"one": @2,
                                     @[ @"three" ]: [NSSet setWithObject:@4],
                                     [NSOrderedSet orderedSetWithObject:@"five"]: @{ @6: @"seven" }
                                     };

        it(@"should describe collections recursively, annotating non-collection types", ^{
            [dictionary cdr_explicitDescription] should equal(@"{\n"
                                                              @"    one (__NSCFConstantString) = 2 (__NSCFNumber),\n"
                                                              @"    (\n"
                                                              @"        three (__NSCFConstantString)\n"
                                                              @"    ) = {(\n"
                                                              @"        4 (__NSCFNumber)\n"
                                                              @"    )},\n"
                                                              @"    {(\n"
                                                              @"        five (__NSCFConstantString)\n"
                                                              @"    )} = {\n"
                                                              @"        6 (__NSCFNumber) = seven (__NSCFConstantString)\n"
                                                              @"    }\n"
                                                              @"}");
        });
    });

    describe(@"NSOrderedSet", ^{
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithObjects:@"one", @2, @[ @"three" ], @{ @4: @"five" }, [NSSet setWithObject:@6], [NSOrderedSet orderedSetWithObject:@"seven"], nil];

        it(@"should describe collections recursively, annotating non-collection types", ^{
            [orderedSet cdr_explicitDescription] should equal(@"{(\n"
                                                              @"    one (__NSCFConstantString),\n"
                                                              @"    2 (__NSCFNumber),\n"
                                                              @"    (\n"
                                                              @"        three (__NSCFConstantString)\n"
                                                              @"    ),\n"
                                                              @"    {\n"
                                                              @"        4 (__NSCFNumber) = five (__NSCFConstantString)\n"
                                                              @"    },\n"
                                                              @"    {(\n"
                                                              @"        6 (__NSCFNumber)\n"
                                                              @"    )},\n"
                                                              @"    {(\n"
                                                              @"        seven (__NSCFConstantString)\n"
                                                              @"    )}\n"
                                                              @")}");
        });
    });

    describe(@"NSSet", ^{
        NSSet *set = [NSSet setWithObjects:@"one", @2, @[ @"three" ], @{ @4: @"five" }, [NSSet setWithObject:@6], [NSOrderedSet orderedSetWithObject:@"seven"], nil];

        it(@"should describe collections recursively, annotating non-collection types", ^{
            NSArray *expectedElementDescriptions = @[@"{(\n",
                                                     @"    one (__NSCFConstantString)",
                                                     @"    2 (__NSCFNumber)",
                                                     @"    (\n        three (__NSCFConstantString)\n    )",
                                                     @"    {\n        4 (__NSCFNumber) = five (__NSCFConstantString)\n    }",
                                                     @"    {(\n        6 (__NSCFNumber)\n    )}",
                                                     @"    {(\n        seven (__NSCFConstantString)\n    )}",
                                                     @")}"];
            NSString *actualExplicitDescription = [set cdr_explicitDescription];
            for (NSString *elementDescription in expectedElementDescriptions) {
                actualExplicitDescription should contain(elementDescription);
            }
            NSInteger expectedNumberOfCommasAndNewLines = (2 * set.count) - 1;
            actualExplicitDescription.length should equal([expectedElementDescriptions componentsJoinedByString:@""].length + expectedNumberOfCommasAndNewLines);
        });
    });
});

SPEC_END
