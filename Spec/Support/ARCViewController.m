#import "ARCViewController.h"

@implementation ARCView @end

@implementation AnotherARCViewController @end

@implementation ARCObject

- (void)someMethod {
    NSLog(@"================> %@", @"This should be stubbed.");
}

@end

@interface ARCViewController ()

@property (strong, nonatomic) NSArray *objects;

@end

@implementation ARCViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    ARCView *subview = [[ARCView alloc] init];
    [self.view addSubview:subview];
    self.weakSubview = subview;

    AnotherARCViewController *childController = [[AnotherARCViewController alloc] init];
    [self addChildViewController:childController];
    self.weakChildController = childController;

    UITextField *textField = [[UITextField alloc] init];
    [self.view addSubview:textField];
    self.weakTextField = textField;

    ARCObject *object = [[ARCObject alloc] init];
    self.objects = @[object];
    self.weakObject = object;
}

@end

