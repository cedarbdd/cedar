#import <WatchKit/WatchKit.h>
#import <Cedar/Cedar.h>

@interface ExtensionDelegate : NSObject <WKExtensionDelegate>
@end

@implementation ExtensionDelegate

- (void)applicationDidFinishLaunching {
    exit(CDRRunSpecs());
}

@end
