#import "CDRExampleDetailsViewController.h"
#import "CDRExampleBase.h"
#import "CDRExampleStateMap.h"

@interface CDRExampleDetailsViewController ()
- (UINavigationBar *)addNavigationBar;
- (CGRect)navigationBarFrame;
- (UILabel *)addLabelWithText:(NSString *)text;
- (void)positionAndSizeLabels;
- (void)minimizeFrameRectForLabel:(UILabel *)label withTop:(float)top andBottom:(float)bottom;
@end

static const float TEXT_LABEL_MARGIN = 20.0;

@implementation CDRExampleDetailsViewController

- (id)initWithExample:(CDRExampleBase *)example {
    if((self = [super init]))
    {
        example_ = [example retain];
    }
    return self;
}

- (void)dealloc {
    [example_ release];
    [self viewDidUnload];
    [super dealloc];
}

#pragma mark View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    navigationBar_ = [self addNavigationBar];
    fullTextLabel_ = [self addLabelWithText:[(id)example_ fullText]];
    messageLabel_ = [self addLabelWithText:[example_ message]];
    [self positionAndSizeLabels];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    navigationBar_.frame = [self navigationBarFrame];
    [self positionAndSizeLabels];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    navigationBar_.frame = [self navigationBarFrame];
    [self positionAndSizeLabels];
}

#pragma mark Target actions
- (void)closeWindow {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark Private interface
- (UINavigationBar *)addNavigationBar {
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:[self navigationBarFrame]];
    [self.view addSubview:navigationBar];
    [navigationBar release];

    NSString *stateName = [[CDRExampleStateMap stateMap] descriptionForState:example_.state];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:stateName];
    [navigationBar pushNavigationItem:navigationItem animated:NO];
    [navigationItem release];

    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeWindow)];
    navigationItem.rightBarButtonItem = closeButton;
    [closeButton release];

    return navigationBar;
}

- (CGRect)navigationBarFrame {
    return CGRectMake(0, 0, self.view.bounds.size.width, 44);
}

- (UILabel *)addLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    label.numberOfLines = 0;
    label.text = text;
    [self.view addSubview:label];
    [label release];

    return label;
}

- (void)positionAndSizeLabels {
    [self minimizeFrameRectForLabel:fullTextLabel_ withTop:navigationBar_.bounds.size.height andBottom:self.view.bounds.size.height / 2];
    [self minimizeFrameRectForLabel:messageLabel_ withTop:fullTextLabel_.frame.origin.y + fullTextLabel_.frame.size.height andBottom:self.view.bounds.size.height];
}

- (void)minimizeFrameRectForLabel:(UILabel *)label withTop:(float)top andBottom:(float)bottom {
    CGRect maximumFrameRect = CGRectMake(TEXT_LABEL_MARGIN, TEXT_LABEL_MARGIN + top, self.view.bounds.size.width - TEXT_LABEL_MARGIN * 2, bottom - top - TEXT_LABEL_MARGIN * 2);
    label.frame = maximumFrameRect;

    CGRect minimumRect = [label textRectForBounds:[label bounds] limitedToNumberOfLines:[label numberOfLines]];
    minimumRect.origin = label.frame.origin;
    label.frame = minimumRect;
}

@end
