#import "ExtensionDelegate.h"
#import <Cedar/Cedar.h>

@implementation ExtensionDelegate

- (void)applicationDidFinishLaunching {
    exit(CDRRunSpecs());
}

@end
