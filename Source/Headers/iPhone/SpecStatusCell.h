#import <UIKit/UIKit.h>

@class CDRExampleBase;

@interface SpecStatusCell : UITableViewCell {
    CDRExampleBase *example_;
}

@property (nonatomic, retain) CDRExampleBase *example;

@end
