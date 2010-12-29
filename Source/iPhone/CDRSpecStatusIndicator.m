#import "CDRSpecStatusIndicator.h"
#import <QuartzCore/QuartzCore.h>

@interface CDRGradientView : UIView
@property(nonatomic, readonly, retain) CAGradientLayer *layer;
@end


@interface CDRSpecStatusIndicator ()
- (void)CDR_commonSpecStatusIndicatorInit;
- (void)CDR_refreshCornerRadiusWithBounds:(CGRect)bounds;
- (CDRGradientView *)CDR_newGradientViewWithStartColor:(UIColor *)start endColor:(UIColor *)end;
@end


@implementation CDRSpecStatusIndicator

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame]))
    {
        [self CDR_commonSpecStatusIndicatorInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super initWithCoder:aDecoder]))
    {
        [self CDR_commonSpecStatusIndicatorInit];
    }
    return self;
}

- (void)dealloc
{
    [_errorLayer   release];
    [_failureLayer release];
    [_pendingLayer release];
    [_successLayer release];
    
    [super dealloc];
}

- (void)CDR_commonSpecStatusIndicatorInit;
{
    CAGradientLayer *rootLayer = (CAGradientLayer *) [self layer];
    
    [rootLayer setType:kCAGradientLayerAxial];
    [rootLayer setColors:[NSArray arrayWithObjects:(id) [[UIColor whiteColor] CGColor], [[UIColor colorWithWhite:0.9 alpha:1.0] CGColor], nil]];
    [rootLayer setLocations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.3], [NSNumber numberWithFloat:1.0], nil]];
    
    [rootLayer setMasksToBounds:YES];
    [rootLayer setBorderColor:[[UIColor blackColor] CGColor]];
    [rootLayer setBorderWidth:1.0];
    [rootLayer setCornerRadius:CGRectGetHeight([self bounds]) / 2.0];
    
    _errorLayer   = [self CDR_newGradientViewWithStartColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]
                                                   endColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
    
    _failureLayer = [self CDR_newGradientViewWithStartColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]
                                                   endColor:[UIColor colorWithRed:0.5 green:0.0 blue:0.0 alpha:1.0]];
    
    _pendingLayer = [self CDR_newGradientViewWithStartColor:[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0]
                                                   endColor:[UIColor colorWithRed:0.6 green:0.6 blue:0.0 alpha:1.0]];
    
    _successLayer = [self CDR_newGradientViewWithStartColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0]
                                                   endColor:[UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0]];
    
    [self addSubview:_errorLayer  ];
    [self addSubview:_failureLayer];
    [self addSubview:_pendingLayer];
    [self addSubview:_successLayer];
}

#pragma mark -
#pragma mark Layer layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = [self bounds];
    
    if(CGRectIsEmpty(bounds)) return; 
    
    [self CDR_refreshCornerRadiusWithBounds:bounds];
    
    CGRect remainderFrame = bounds;
    CGRect errorFrame, failureFrame, pendingFrame, successFrame;
    
    CGRectDivide(remainderFrame, &errorFrame  , &remainderFrame, round(CGRectGetWidth(bounds) * _errorValue  ), CGRectMinXEdge);
    CGRectDivide(remainderFrame, &failureFrame, &remainderFrame, round(CGRectGetWidth(bounds) * _failureValue), CGRectMinXEdge);
    CGRectDivide(remainderFrame, &pendingFrame, &remainderFrame, round(CGRectGetWidth(bounds) * _pendingValue), CGRectMinXEdge);
    CGRectDivide(remainderFrame, &successFrame, &remainderFrame, round(CGRectGetWidth(bounds) * _successValue), CGRectMinXEdge);
    
    [_errorLayer   setFrame:errorFrame  ];
    [_failureLayer setFrame:failureFrame];
    [_pendingLayer setFrame:pendingFrame];
    [_successLayer setFrame:successFrame];
}

- (void)CDR_refreshCornerRadiusWithBounds:(CGRect)bounds;
{
    [[self layer] setCornerRadius:CGRectGetHeight(bounds) / 2.0];
}

- (CDRGradientView *)CDR_newGradientViewWithStartColor:(UIColor *)start endColor:(UIColor *)end;
{
    CDRGradientView *ret = [[CDRGradientView alloc] init];
    
    CAGradientLayer *grad = [ret layer];
    
    [grad setType:kCAGradientLayerAxial];
    [grad setColors:[NSArray arrayWithObjects:(id) [start CGColor], [end CGColor], nil]];
    [grad setLocations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil]];
    
    return ret;
}

#pragma mark -
#pragma mark Accessors

- (CGFloat)errorValue { return _errorValue; }
- (void)setErrorValue:(CGFloat)value
{
    // Ensures the value is between 0.0 and 1.0
    value = MAX(0.0, MIN(1.0, value));
    
    if(_errorValue != value)
    {
        _errorValue = value;
        
        [self setNeedsLayout];
    }
}

- (CGFloat)failureValue { return _failureValue; }
- (void)setFailureValue:(CGFloat)value
{
    // Ensures the value is between 0.0 and 1.0
    value = MAX(0.0, MIN(1.0, value));
    
    if(_failureValue != value)
    {
        _failureValue = value;
        [self setNeedsLayout];
    }
}

- (CGFloat)pendingValue { return _pendingValue; }
- (void)setPendingValue:(CGFloat)value
{
    // Ensures the value is between 0.0 and 1.0
    value = MAX(0.0, MIN(1.0, value));
    
    if(_pendingValue != value)
    {
        _pendingValue = value;
        [self setNeedsLayout];
    }
}

- (CGFloat)successValue { return _successValue; }
- (void)setSuccessValue:(CGFloat)value
{
    // Ensures the value is between 0.0 and 1.0
    value = MAX(0.0, MIN(1.0, value));
    
    if(_successValue != value)
    {
        _successValue = value;
        [self setNeedsLayout];
    }
}

@end


@implementation CDRGradientView
@dynamic layer;

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

@end
