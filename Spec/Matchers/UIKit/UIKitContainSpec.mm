#if TARGET_OS_IPHONE
#import "SpecHelper.h"
#else
#error This spec is only valid for targets which link UIKit
#endif

extern "C" {
#import "ExpectFailureWithMessage.h"
}

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(UIKitContainSpec)

describe(@"UIKit contain matcher", ^{
    describe(@"when the container is a UIView", ^{
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
            parentView should contain(childView);
        });

        it(@"should fail for views that are nested subviews of the view", ^{
            expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to contain <%@>", parentView, grandchildView], ^{
                parentView should contain(grandchildView);
            });
        });

        it(@"should fail for views that are not contained by the view in its hierarchy", ^{
            expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to contain <%@>", parentView, orphanView], ^{
                parentView should contain(orphanView);
            });
        });

        describe(@"negative matcher", ^{
            it(@"should pass for views that are not contained by the view in its hierarchy", ^{
                parentView should_not contain(orphanView);
            });

            it(@"should fail for views that are subviews of the view", ^{
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not contain <%@>", parentView, childView], ^{
                    parentView should_not contain(childView);
                });
            });
        });

        describe(@"with the 'nested' modifier", ^{
            it(@"should pass for views that are nested subviews of the view", ^{
                parentView should contain(grandchildView).nested();
            });

            describe(@"negative matcher", ^{
                it(@"should fail for views that are nested subviews of the view", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not contain <%@> nested", parentView, grandchildView], ^{
                        parentView should_not contain(grandchildView).nested();
                    });
                });
            });
        });
    });

    describe(@"when the container is a CALayer", ^{
        __block CALayer *parentLayer;
        __block CALayer *childLayer;
        __block CALayer *grandchildLayer;
        __block CALayer *orphanLayer;

        beforeEach(^{
            parentLayer = [[CALayer alloc] init];
            childLayer = [[CALayer alloc] init];
            grandchildLayer = [[CALayer alloc] init];
            orphanLayer = [[CALayer alloc] init];

            [parentLayer addSublayer:childLayer];
            [childLayer addSublayer:grandchildLayer];
        });

        it(@"should pass for layers that are sublayers of the layer", ^{
            parentLayer should contain(childLayer);
        });

        it(@"should fail for layers that are nested sublayers of the layer", ^{
            expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to contain <%@>", parentLayer, grandchildLayer], ^{
                parentLayer should contain(grandchildLayer);
            });
        });

        it(@"should fail for layers that are not contained by the layer in its hierarchy", ^{
            expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to contain <%@>", parentLayer, orphanLayer], ^{
                parentLayer should contain(orphanLayer);
            });
        });

        describe(@"negative matcher", ^{
            it(@"should pass for layers that are not contained by the layer in its hierarchy", ^{
                parentLayer should_not contain(orphanLayer);
            });

            it(@"should fail for layers that are sublayers of the layer", ^{
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not contain <%@>", parentLayer, childLayer], ^{
                    parentLayer should_not contain(childLayer);
                });
            });
        });

        describe(@"with the 'nested' modifier", ^{
            it(@"should pass for layers that are nested sublayers of the layer", ^{
                parentLayer should contain(grandchildLayer).nested();
            });

            describe(@"negative matcher", ^{
                it(@"should fail for layers that are nested sublayers of the layer", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not contain <%@> nested", parentLayer, grandchildLayer], ^{
                        parentLayer should_not contain(grandchildLayer).nested();
                    });
                });
            });
        });
    });

});

SPEC_END
