#import <UIKit/UIKit.h>

@interface AnotherARCViewController : UIViewController @end

@interface ARCView : UIView @end

@interface ARCViewController : UIViewController

@property (weak, nonatomic) ARCView *someSubview;
@property (weak, nonatomic) AnotherARCViewController *someChildController;
@property (weak, nonatomic) UITextField *textField;

@end
