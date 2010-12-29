#import "CDRSpecStatusCell.h"
#import "CDRSpecStatusIndicator.h"

@interface CDRSpecStatusCell ()
- (void)CDR_commonSpecStatusCellInit;
- (NSString *)CDR_summaryConstrainedToWidth:(CGFloat)width;
- (void)CDR_refreshIndicatorView;
- (void)CDR_refreshContent;
- (void)CDR_refreshSummary;
@end


@implementation CDRSpecStatusCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self != nil)
    {
        [self CDR_commonSpecStatusCellInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super initWithCoder:aDecoder]))
    {
        [self CDR_commonSpecStatusCellInit];
    }
    return self;
}

- (void)CDR_commonSpecStatusCellInit;
{
    _indicatorView  = [[CDRSpecStatusIndicator alloc] init];
    
    _testTitleLabel = [[UILabel alloc] init];
    _summaryLabel   = [[UILabel alloc] init];
    
    [_testTitleLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
    [_testTitleLabel setTextColor:[UIColor blackColor]];
    [_testTitleLabel setHighlightedTextColor:[UIColor whiteColor]];
    
    [_summaryLabel   setFont:[UIFont systemFontOfSize:14.0]];
    [_summaryLabel   setTextColor:[UIColor grayColor]];
    [_summaryLabel   setHighlightedTextColor:[UIColor whiteColor]];
    
    UIView *contentView = [self contentView];
    
    [contentView addSubview:_indicatorView];
    [contentView addSubview:_testTitleLabel];
    [contentView addSubview:_summaryLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    
    //[super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc
{
    [_indicatorView  release];
    [_testTitleLabel release];
    [_summaryLabel   release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Content refresh

- (void)CDR_refreshContent;
{
    [self CDR_refreshSummary];
    [self CDR_refreshIndicatorView];
}

- (NSString *)CDR_summaryConstrainedToWidth:(CGFloat)width
{
    NSString *ret = [NSString stringWithFormat:@"Errors: %u, Failures: %u, Pending: %u, Success: %u, Total: %u", _errorCount, _failureCount, _pendingCount, _successCount, _totalCount];
    
    if([ret sizeWithFont:[_summaryLabel font]].width > width)
        ret = [NSString stringWithFormat:@"E: %u, F: %u, P: %u, S: %u, T: %u", _errorCount, _failureCount, _pendingCount, _successCount, _totalCount];
    
    return ret;
}

- (void)CDR_refreshSummary;
{
    [_summaryLabel setText:[self CDR_summaryConstrainedToWidth:CGRectGetWidth([_summaryLabel frame])]];
}

- (void)CDR_refreshIndicatorView;
{
    [_indicatorView setErrorValue:  _errorCount   / (CGFloat)_totalCount];
    [_indicatorView setFailureValue:_failureCount / (CGFloat)_totalCount];
    [_indicatorView setPendingValue:_pendingCount / (CGFloat)_totalCount];
    [_indicatorView setSuccessValue:_successCount / (CGFloat)_totalCount];
}

#pragma mark -
#pragma mark Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = CGRectInset([[self contentView] bounds], 10.0, 2.0);
    
    CGRect testTitleFrame = bounds, summaryFrame = bounds, indicatorFrame = bounds;
    
    testTitleFrame.size.height = [_testTitleLabel sizeThatFits:bounds.size].height;
    
    summaryFrame.origin.y    = CGRectGetMaxY(testTitleFrame) + 2.0;
    summaryFrame.size.height = [_summaryLabel sizeThatFits:bounds.size].height;
    
    indicatorFrame.origin.y    = CGRectGetMaxY(summaryFrame) + 4.0;
    indicatorFrame.size.height = CGRectGetMaxY(bounds) - CGRectGetMinY(indicatorFrame) - 2.0;
    
    [_testTitleLabel setFrame:testTitleFrame];
    [_summaryLabel   setFrame:summaryFrame];
    [_indicatorView  setFrame:indicatorFrame];
    
    [self CDR_refreshSummary];
}

#pragma mark -
#pragma mark Accessors;

- (NSString *)testTitle                { return [_testTitleLabel text]; }
- (void)setTestTitle:(NSString *)value { [_testTitleLabel setText:value]; }

- (NSUInteger)errorCount { return _errorCount; }
- (void)setErrorCount:(NSUInteger)value
{
    if(_errorCount != value)
    {
        _errorCount = value;
        [self CDR_refreshContent];
    }
}

- (NSUInteger)failureCount { return _failureCount; }
- (void)setFailureCount:(NSUInteger)value
{
    if(_failureCount != value)
    {
        _failureCount = value;
        [self CDR_refreshContent];
    }
}

- (NSUInteger)pendingCount { return _pendingCount; }
- (void)setPendingCount:(NSUInteger)value
{
    if(_pendingCount != value)
    {
        _pendingCount = value;
        [self CDR_refreshContent];
    }
}

- (NSUInteger)successCount { return _successCount; }
- (void)setSuccessCount:(NSUInteger)value
{
    if(_successCount != value)
    {
        _successCount = value;
        [self CDR_refreshContent];
    }
}

- (NSUInteger)totalCount { return _totalCount; }
- (void)setTotalCount:(NSUInteger)value
{
    if(_totalCount != value)
    {
        _totalCount = value;
        [self CDR_refreshContent];
    }
}

@end
