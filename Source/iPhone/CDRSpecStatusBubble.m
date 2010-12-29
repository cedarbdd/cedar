#import "CDRSpecStatusBubble.h"
#import <QuartzCore/QuartzCore.h>

@interface CDRSpecStatusBubble ()
- (void)CDR_refreshColorForState:(CDRExampleState)value;
- (NSArray *)CDR_colorsForState:(CDRExampleState)value;
- (void)CDR_commonSpecStatusBubbleInit;
@end


@implementation CDRSpecStatusBubble

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self != nil)
    {
        [self CDR_commonSpecStatusBubbleInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super initWithCoder:aDecoder]))
    {
        [self CDR_commonSpecStatusBubbleInit];
    }
    return self;
}

- (void)CDR_commonSpecStatusBubbleInit;
{
    CAGradientLayer *layer = (CAGradientLayer *) [self layer];
    
    [layer setCornerRadius:10.0];
    [layer setBorderColor:[[UIColor blackColor] CGColor]];
    [layer setBorderWidth:1.0];
    [layer setMasksToBounds:YES];
    
    [layer setType:kCAGradientLayerAxial];
    [layer setLocations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil]];
}

- (void)setFrame:(CGRect)value
{
    [super setFrame:CGRectMake(CGRectGetMinX(value), CGRectGetMinY(value), 20.0, 20.0)];
}

- (void)setBounds:(CGRect)value
{
    [super setBounds:CGRectMake(CGRectGetMinX(value), CGRectGetMinY(value), 20.0, 20.0)];
}

- (void)CDR_refreshColorForState:(CDRExampleState)value;
{
    CAGradientLayer *layer = (CAGradientLayer *) [self layer];
    
    [layer setColors:[self CDR_colorsForState:value]];
}

- (NSArray *)CDR_colorsForState:(CDRExampleState)value;
{
    UIColor *start = nil, *end = nil;
    
    switch(value)
    {
        case CDRExampleStateIncomplete :
            start = [UIColor whiteColor];
            end   = [UIColor colorWithWhite:0.9 alpha:1.0];
            break;
        case CDRExampleStatePassed     :
            start = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
            end   = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
            break;
        case CDRExampleStatePending    :
            start = [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0];
            end   = [UIColor colorWithRed:0.6 green:0.6 blue:0.0 alpha:1.0];
            break;
        case CDRExampleStateFailed     :
            start = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
            end   = [UIColor colorWithRed:0.5 green:0.0 blue:0.0 alpha:1.0];
            break;
        case CDRExampleStateError      :
            start = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
            end   = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
            break;
        default:
            return nil;
    }
    
    return [NSArray arrayWithObjects:(id) [start CGColor], [end CGColor], nil];
}

- (CDRExampleState)state; { return _state; }
- (void)setState:(CDRExampleState)value;
{
    if(_state != value)
    {
        _state = value;
        [self CDR_refreshColorForState:value];
    }
}



@end
