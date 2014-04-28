#import <UIKit/UIKit.h>

// In some cases CDRIPhoneOTestRunner needs to spin up an instance of Cedar app.
// It appears that SenTestingKit fails to start up the test when CedarApplicationDelegate
// is used. Solution is to use a subclass of UIApplicaton.
@interface CedarApplication : UIApplication
@end

// Needed for backwards compatibility with existing projects using CedarApplicationDelegate
@interface CedarApplicationDelegate : NSObject <UIApplicationDelegate>
@end
