#import <UIKit/UIKit.h>

@class CDRExampleRunnerViewController;

@interface CedarApplicationDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window_;
    CDRExampleRunnerViewController *viewController_;
}

@end
