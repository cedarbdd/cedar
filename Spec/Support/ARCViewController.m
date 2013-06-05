#import "ARCViewController.h"

@implementation ARCViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIView *subview = [[UIView alloc] init];
    [self.view addSubview:subview];
    self.someSubview = subview;

    UIViewController *childController = [[UIViewController alloc] init];
    [self addChildViewController:childController];
    self.someChildController = childController;
}

@end
