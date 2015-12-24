#import "Cedar.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CDRSpecSpec)

describe(@"CDRSpec", ^{
    __block CDRSpec *spec;

    beforeEach(^{
        spec = [[[CDRSpec alloc] init] autorelease];

        spy_on(spec.symbolicator);
        spec.symbolicator stub_method("symbolicateAddresses:error:").and_return(YES);
        spec.symbolicator stub_method("lineNumberForStackAddress:").and_do(^(NSInvocation *i){
            NSUInteger lineNumber;
            [i getArgument:&lineNumber atIndex:2];
            [i setReturnValue:&lineNumber];
        });
    });

    CDRExampleGroup *(^exampleGroup)(int) = ^(int lineNumber){
        CDRExampleGroup *group = [[[CDRExampleGroup alloc] initWithText:@"Group"] autorelease];
        group.stackAddress = lineNumber;
        return group;
    };

    describe(@"-markAsFocusedClosestToLineNumber:", ^{
        context(@"with a single group", ^{
            it(@"marks group as focused if line number is above the group", ^{
                spec.rootGroup = exampleGroup(1);
                [spec markAsFocusedClosestToLineNumber:0];
                spec.rootGroup.isFocused should be_truthy;
            });

            it(@"marks group as focused if line number is exactly on the first line of the group", ^{
                spec.rootGroup = exampleGroup(1);
                [spec markAsFocusedClosestToLineNumber:1];
                spec.rootGroup.isFocused should be_truthy;
            });

            it(@"marks group as focused if line number is below the first line of the group", ^{
                spec.rootGroup = exampleGroup(1);
                [spec markAsFocusedClosestToLineNumber:2];
                spec.rootGroup.isFocused should be_truthy;
            });
        });

        context(@"with a group that contains another group", ^{
            it(@"marks outer group as focused if line number is below the first line of outer group and above the first line of inner group", ^{
                spec.rootGroup = exampleGroup(1);

                CDRExampleGroup *innerGroup = exampleGroup(3);
                [spec.rootGroup add:innerGroup];

                [spec markAsFocusedClosestToLineNumber:2];
                spec.rootGroup.isFocused should be_truthy;
                innerGroup.isFocused should_not be_truthy;
            });

            it(@"marks inner group as focused if line number is below the first line of outer group and exactly on the first line of inner group", ^{
                spec.rootGroup = exampleGroup(1);

                CDRExampleGroup *innerGroup = exampleGroup(3);
                [spec.rootGroup add:innerGroup];

                [spec markAsFocusedClosestToLineNumber:3];
                spec.rootGroup.isFocused should_not be_truthy;
                innerGroup.isFocused should be_truthy;
            });

            it(@"marks inner group as focused if line number is below both first lines of outer and inner groups", ^{
                spec.rootGroup = exampleGroup(1);

                CDRExampleGroup *innerGroup = exampleGroup(3);
                [spec.rootGroup add:innerGroup];

                [spec markAsFocusedClosestToLineNumber:5];
                spec.rootGroup.isFocused should_not be_truthy;
                innerGroup.isFocused should be_truthy;
            });
        });
    });
});

SPEC_END
