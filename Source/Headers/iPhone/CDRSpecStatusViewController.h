#import <UIKit/UIKit.h>

@interface CDRSpecStatusViewController : UITableViewController
{
@private
    NSArray         *examples_;
}

- (id)initWithExamples:(NSArray *)examples;

@end
