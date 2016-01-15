#import "Cedar.h"
#import "ExpectFailureWithMessage.h"

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
            parentView = [[[UIView alloc] init] autorelease];
            childView = [[[UIView alloc] init] autorelease];
            grandchildView = [[[UIView alloc] init] autorelease];
            orphanView = [[[UIView alloc] init] autorelease];

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

        describe(@"matching based on object class", ^{
            describe(@"positive match", ^{
                it(@"should pass when checking for an instance of the exact class", ^{
                    parentView should contain(an_instance_of([UIView class]));
                });

                it(@"should not pass when checking for an instance of a superclass", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to contain <an instance of UIResponder>", parentView], ^{
                        parentView should contain(an_instance_of([UIResponder class]));
                    });
                });

                context(@"when including subclasses", ^{
                    it(@"should pass when checking for an instance of a superclass", ^{
                         parentView should contain(an_instance_of([UIResponder class]).or_any_subclass());
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not contain <an instance of UIView>", parentView], ^{
                        parentView should_not contain(an_instance_of([UIView class]));
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
            parentLayer = [[[CALayer alloc] init] autorelease];
            childLayer = [[[CALayer alloc] init] autorelease];
            grandchildLayer = [[[CALayer alloc] init] autorelease];
            orphanLayer = [[[CALayer alloc] init] autorelease];

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

        describe(@"matching based on object class", ^{
            describe(@"positive match", ^{
                it(@"should pass when checking for an instance of the exact class", ^{
                    parentLayer should contain(an_instance_of([CALayer class]));
                });

                it(@"should not pass when checking for an instance of a superclass", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to contain <an instance of NSObject>", parentLayer], ^{
                        parentLayer should contain(an_instance_of([NSObject class]));
                    });
                });

                context(@"when including subclasses", ^{
                    it(@"should pass when checking for an instance of a superclass", ^{
                        parentLayer should contain(an_instance_of([NSObject class]).or_any_subclass());
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not contain <an instance of CALayer>", parentLayer], ^{
                        parentLayer should_not contain(an_instance_of([CALayer class]));
                    });
                });
            });
        });
    });

});

SPEC_END
