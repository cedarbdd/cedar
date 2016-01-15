#import "Cedar.h"
#import "iOSHostAppDelegate.h" // should NOT be included in Cedar iOS SpecBundle target

using namespace Cedar::Matchers;

SPEC_BEGIN(SpecBundleApplicationTests)

describe(@"A spec file testing UI", ^{
    it(@"should run", ^{
        UILabel *label = [[[UILabel alloc] init] autorelease];
        expect([label class]).to(equal([UILabel class]));
    });

    it(@"should be able to access classes that are included in the app bundle but are not directly included in the application tests bundle", ^{
        // For that to work app target must have 'Strip Debug Symbols During Copy' set to NO.
        expect([iOSHostAppDelegate class]).to(equal([iOSHostAppDelegate class]));
    });

    it(@"should have its main bundle set to be the app bundle", ^{
        expect([[NSBundle mainBundle].bundlePath hasSuffix:@".app"]).to(be_truthy());
    });

    it(@"should be able to load nib files from the app bundle", ^{
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"DummyView" owner:nil options:nil];
        expect([views lastObject]).to(be_instance_of([UIView class]));
    });
});

SPEC_END
