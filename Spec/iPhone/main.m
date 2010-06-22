#import <UIKit/UIKit.h>

// Normally Cedar.h would include these files.  However, you can't have the specs
// for the spec classes include the files that define the classes that implement
// the specs.  Is your head spinning?  It should be.
#import "CDRFunctions.h"
#import "CedarApplicationDelegate.h"
#import "CDRExampleRunnerViewController.h"

int main(int argc, char *argv[]) {
    @try {
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

        int retVal = UIApplicationMain(argc, argv, nil, @"CedarApplicationDelegate");
        [pool release];
        return retVal;
    } @catch (NSString *x) {
        NSLog(@"=====================> NSString exception: %@", x);
    } @catch (NSException *x) {
        NSLog(@"=====================> NSException: %@", x);
    }
}
