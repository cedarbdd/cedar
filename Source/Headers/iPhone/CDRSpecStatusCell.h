#import <UIKit/UIKit.h>

@class CDRSpecStatusIndicator;

@interface CDRSpecStatusCell : UITableViewCell
{
@private
    CDRSpecStatusIndicator *_indicatorView;
    UILabel                *_testTitleLabel;
    UILabel                *_summaryLabel;
    
    NSUInteger              _errorCount;
    NSUInteger              _failureCount;
    NSUInteger              _pendingCount;
    NSUInteger              _successCount;
    NSUInteger              _totalCount;
}

@property(nonatomic, copy) NSString *testTitle;

@property(nonatomic) NSUInteger errorCount;
@property(nonatomic) NSUInteger failureCount;
@property(nonatomic) NSUInteger pendingCount;
@property(nonatomic) NSUInteger successCount;
@property(nonatomic) NSUInteger totalCount;

@end
