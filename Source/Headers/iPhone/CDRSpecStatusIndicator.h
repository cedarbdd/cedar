#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CDRSpecStatusIndicator : UIView
{
@private
    UIView  *_errorLayer;
    UIView  *_failureLayer;
    UIView  *_pendingLayer;
    UIView  *_successLayer;
    
    CGFloat  _errorValue;
    CGFloat  _failureValue;
    CGFloat  _pendingValue;
    CGFloat  _successValue;
}

@property(nonatomic) CGFloat errorValue;
@property(nonatomic) CGFloat failureValue;
@property(nonatomic) CGFloat pendingValue;
@property(nonatomic) CGFloat successValue;

@end
