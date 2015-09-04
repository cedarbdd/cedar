#import <UIKit/UIKit.h>

// Normally Cedar-iOS.h would include these files.  However, you can't have the specs
// for the spec classes include the files that define the classes that implement
// the specs.  Is your head spinning?  It should be.
#import "CedarApplicationDelegate.h"

int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    int retVal = UIApplicationMain(argc, argv, nil, @"CedarApplicationDelegate");
    [pool release];
    return retVal;
}
