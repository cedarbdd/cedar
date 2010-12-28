#import <UIKit/UIKit.h>
#import <Cedar/CDRSpec.h>

@interface CDRSpecStatusBubble : UIView
{
@private
    CDRExampleState _state;
}

@property(nonatomic) CDRExampleState state;

@end
