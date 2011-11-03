#import <UIKit/UIKit.h>

typedef void (^CDRExampleDetailsViewControllerCompletionHandler)(void);

@class CDRExampleBase;

@interface CDRExampleDetailsViewController : UIViewController {
    CDRExampleBase *example_;
    UINavigationBar *navigationBar_;
    UILabel *fullTextLabel_, *messageLabel_;
    CDRExampleDetailsViewControllerCompletionHandler completion_;
}

- (id)initWithExample:(CDRExampleBase *)example;

@property (nonatomic, copy) CDRExampleDetailsViewControllerCompletionHandler completion;
           


@end
