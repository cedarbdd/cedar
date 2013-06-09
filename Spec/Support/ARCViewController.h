#import <UIKit/UIKit.h>

@interface AnotherARCViewController : UIViewController @end

@interface ARCView : UIView @end

@interface ARCObject : NSObject

- (void)someMethod;

@end

@interface ARCViewController : UIViewController

@property (weak, nonatomic) ARCView *weakSubview;
@property (weak, nonatomic) AnotherARCViewController *weakChildController;
@property (weak, nonatomic) UITextField *weakTextField;
@property (weak, nonatomic) ARCObject *weakObject;

@end
