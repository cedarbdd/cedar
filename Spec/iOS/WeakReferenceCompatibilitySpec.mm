#import "Cedar.h"
#import "ObjectWithWeakDelegate.h"
#import "ARCViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(WeakReferenceCompatibilitySpec)

// This spec exists as a regression test to ensure that Cedar Doubles continue
// to work with the iOS 5 runtime.
//
// For more info please see http://openradar.appspot.com/11117786
// or http://stackoverflow.com/questions/8675054/why-is-my-objects-weak-delegate-property-nil-in-my-unit-tests

describe(@"An object with a weak reference to a Cedar Double", ^{
    __block ObjectWithWeakDelegate *object;

    beforeEach(^{
        id<ExampleDelegate> fakeDelegate = nice_fake_for(@protocol(ExampleDelegate));
        object = [[[ObjectWithWeakDelegate alloc] init] autorelease];
        object.delegate = fakeDelegate;
    });

    it(@"should have the Double as a delegate", ^{
        object.delegate should_not be_nil;
    });

    describe(@"when sending a message", ^{
        beforeEach(^{
            [object tellTheDelegate];
        });

        it(@"should result in the double having received the message", ^{
            object.delegate should have_received(@selector(someMessage));
        });
    });
});

describe(@"A UIViewController subclass compiled under ARC", ^{
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSInteger majorVersion = [[[systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] integerValue];

    if (majorVersion < 6) {
        describe(@"when tests are run on the iOS 5.x runtime", ^{
            it(@"should be possible to spy directly on weak references, but isn't (http://openradar.appspot.com/11117786).  Spy on a strong reference instead as a workaround.", PENDING);
        });
    } else {
        __block ARCViewController *controller;

        beforeEach(^{
            controller = [[[ARCViewController alloc] init] autorelease];
            controller.view should_not be_nil;
        });

        describe(@"spying on a weakly referred-to subview property", ^{
            beforeEach(^{
                spy_on(controller.weakSubview);

                [controller.weakSubview layoutIfNeeded];
            });

            it(@"should allow recording of sent messages, and not blow up on dealloc", ^{
                controller.weakSubview should have_received("layoutIfNeeded");
            });
        });

        describe(@"spying on a weakly referred-to child controller", ^{
            beforeEach(^{
                spy_on(controller.weakChildController);

                [controller.weakChildController isViewLoaded];
            });

            it(@"should allow recording of sent messages, and not blow up on dealloc", ^{
                controller.weakChildController should have_received("isViewLoaded");
            });
        });

        describe(@"spying on a weakly referred-to text field", ^{
            beforeEach(^{
                spy_on(controller.weakTextField);

                [controller.weakTextField becomeFirstResponder];
            });

            it(@"should allow recording of sent messages, and not blow up on dealloc", ^{
                controller.weakTextField should have_received("becomeFirstResponder");
            });
        });

        describe(@"spying on a weakly referred-to object not from UIKit", ^{
            beforeEach(^{
                spy_on(controller.weakObject);

                controller.weakObject stub_method("someMethod");
                [controller.weakObject someMethod];
            });

            it(@"should allow recording of sent messages, and not blow up on dealloc", ^{
                controller.weakObject should have_received("someMethod");
            });
        });
    }
});

SPEC_END
