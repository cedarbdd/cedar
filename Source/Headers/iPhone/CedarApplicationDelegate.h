#import <UIKit/UIKit.h>
#import <Cedar/CDRExampleReporter.h>

@interface CedarApplicationDelegate : NSObject <UIApplicationDelegate, CDRExampleReporter>
{
@private
    UIWindow               *_window;
    UINavigationController *_viewController;
}

@end
