#import "ARCViewController.h"

@implementation ARCView @end

@implementation AnotherARCViewController @end

@implementation ARCViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    ARCView *subview = [[ARCView alloc] init];
    [self.view addSubview:subview];
    self.someSubview = subview;

    AnotherARCViewController *childController = [[AnotherARCViewController alloc] init];
    [self addChildViewController:childController];
    self.someChildController = childController;

    UITextField *textField = [[UITextField alloc] init];
    [self.view addSubview:textField];
    self.textField = textField;
}

@end
