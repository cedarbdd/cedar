#import <Foundation/Foundation.h>
#import "CDRExampleParent.h"

@class CDRSpec, CDRReportDispatcher;

enum CDRExampleState {
    CDRExampleStateIncomplete = 0x00,
    CDRExampleStateSkipped = 0x01,
    CDRExampleStatePassed = 0x03,
    CDRExampleStatePending = 0x07,
    CDRExampleStateFailed = 0x0F,
    CDRExampleStateError = 0x1F
};
typedef enum CDRExampleState CDRExampleState;

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
@property (nonatomic, assign) NSObject<CDRExampleParent> *parent;
@property (nonatomic, assign) CDRSpec *spec;
@property (nonatomic, assign, getter=isFocused) BOOL focused;
@property (nonatomic) NSUInteger stackAddress;
@property (nonatomic, readonly) NSDate *startDate;
@property (nonatomic, readonly) NSDate *endDate;

- (id)initWithText:(NSString *)text;


- (void)runWithDispatcher:(CDRReportDispatcher *)dispatcher;
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
