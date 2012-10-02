#import "SpecHelper.h"
#import "CDRExample.h"
#import "CDRExampleGroup.h"
#import "CDRSymbolicator.h"

using namespace Cedar::Matchers;

#if !__arm__
SPEC_BEGIN(CDRSymbolicatorSpec)

describe(@"CDRSymbolicator", ^{
    __block CDRExample *example;
    __block CDRExampleGroup *group;

    void (^verifyFileNameAndLineNumber)(CDRExampleBase *, NSString *, int) =
        ^(CDRExampleBase *b, NSString *fileName, int lineNumber) {
            NSNumber *address = [NSNumber numberWithUnsignedInteger:b.stackAddress];
            NSArray *addresses = [NSArray arrayWithObject:address];

            CDRSymbolicator *symbolicator = [[CDRSymbolicator alloc] init];
            [symbolicator symbolicateAddresses:addresses];

            [[symbolicator fileNameForStackAddress:b.stackAddress] hasSuffix:fileName] should be_truthy;
            [symbolicator lineNumberForStackAddress:b.stackAddress] should equal(lineNumber);
            [symbolicator release];
        };

    it(@"identifies file name and line number of an it", ^{
        example = it(@"it", ^{});
        verifyFileNameAndLineNumber(example, @"CDRSymbolicatorSpec.mm", __LINE__-1);
    });

    it(@"identifies file name line number of a describe", ^{
        group = describe(@"describe", ^{});
        verifyFileNameAndLineNumber(group, @"CDRSymbolicatorSpec.mm", __LINE__-1);
    });

    it(@"identifies file name line number of a context", ^{
        group = context(@"context", ^{});
        verifyFileNameAndLineNumber(group, @"CDRSymbolicatorSpec.mm", __LINE__-1);
    });

    it(@"identifies file name line number of a nested it", ^{
        describe(@"describe", ^{
            example = it(@"it", ^{});
        });
        verifyFileNameAndLineNumber(example, @"CDRSymbolicatorSpec.mm", __LINE__-2);
    });

    it(@"identifies file name line number of a nested describe", ^{
        describe(@"describe", ^{
            group = describe(@"describe", ^{});
        });
        verifyFileNameAndLineNumber(group, @"CDRSymbolicatorSpec.mm", __LINE__-2);
    });

    it(@"identifies file name line number of a nested context", ^{
        describe(@"describe", ^{
            group = context(@"context", ^{});
        });
        verifyFileNameAndLineNumber(group, @"CDRSymbolicatorSpec.mm", __LINE__-2);
    });
});

SPEC_END
#endif
