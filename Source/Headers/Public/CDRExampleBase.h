#import <Foundation/Foundation.h>
#import "CDRNullabilityCompat.h"
#import "CDRExampleParent.h"

NS_ASSUME_NONNULL_BEGIN

@class CDRSpec, CDRReportDispatcher;
typedef NS_ENUM(NSInteger, CDRExampleState) {
    CDRExampleStateIncomplete = 0x00,
    CDRExampleStateSkipped = 0x01,
    CDRExampleStatePassed = 0x03,
    CDRExampleStatePending = 0x07,
    CDRExampleStateFailed = 0x0F,
    CDRExampleStateError = 0x1F
};

@interface CDRExampleBase : NSObject {
  NSString *text_;
  NSObject<CDRExampleParent> *parent_;
  CDRSpec *spec_;
  BOOL focused_;
  NSUInteger stackAddress_;
  NSDate *startDate_;
  NSDate *endDate_;
}

@property (nonatomic, readonly) NSString *text;
@property (nonatomic, assign, nullable) NSObject<CDRExampleParent> *parent;
@property (nonatomic, assign, nullable) CDRSpec *spec;
@property (nonatomic, assign, getter=isFocused) BOOL focused;
@property (nonatomic) NSUInteger stackAddress;
@property (nonatomic, readonly, nullable) NSDate *startDate;
@property (nonatomic, readonly, nullable) NSDate *endDate;

- (id)initWithText:(NSString *)text;


- (void)runWithDispatcher:(nullable CDRReportDispatcher *)dispatcher;
- (BOOL)shouldRun;

- (BOOL)hasChildren;
- (BOOL)hasFocusedExamples;

- (NSString *)message;
- (NSString *)fullText;
- (NSMutableArray *)fullTextInPieces;

- (NSTimeInterval)runTime;
- (CDRExampleState)state;
@end

@interface CDRExampleBase (RunReporting)
- (float)progress;
@end

NS_ASSUME_NONNULL_END
