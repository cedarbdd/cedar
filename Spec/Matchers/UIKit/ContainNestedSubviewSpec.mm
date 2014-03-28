#if TARGET_OS_IPHONE
#import "SpecHelper.h"
#else
#error This spec is only valid for targets which link UIKit
#endif

extern "C" {
#import "ExpectFailureWithMessage.h"
}

using namespace Cedar::Matchers;

SPEC_BEGIN(ContainNestedSubviewSpec)

describe(@"contain_nested_subview matcher", ^{
    __block UIView *parentView;
    __block UIView *childView;
    __block UIView *grandchildView;
    __block UIView *orphanView;

    beforeEach(^{
        parentView = [[UIView alloc] init];
        childView = [[UIView alloc] init];
        grandchildView = [[UIView alloc] init];
        orphanView = [[UIView alloc] init];

        [parentView addSubview:childView];
        [childView addSubview:grandchildView];
    });

    it(@"should pass for views that are subviews of the view", ^{
        parentView should contain_nested_subview(childView);
    });

    it(@"should pass for views that are nested subviews of the view", ^{
        parentView should contain_nested_subview(grandchildView);
    });

    it(@"should fail for views that are not contained by the view in its heirarchy", ^{
        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to contain nested subview <%@>", parentView, orphanView], ^{
            parentView should contain_nested_subview(orphanView);
        });
    });

    describe(@"negative matcher", ^{
        it(@"should pass for views that are not contained by the view in its hierarchy", ^{
            parentView should_not contain_nested_subview(orphanView);
        });

        it(@"should fail for views that are not contained by the view in its heirarchy", ^{
            expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not contain nested subview <%@>", parentView, grandchildView], ^{
                parentView should_not contain_nested_subview(grandchildView);
            });
        });
    });
});

SPEC_END
