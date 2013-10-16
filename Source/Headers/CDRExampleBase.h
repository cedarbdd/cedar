#import <Foundation/Foundation.h>
#import "CDRExampleParent.h"

@protocol CDRExampleReporter;

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
  BOOL focused_;
  NSTimeInterval runTime_;
  NSUInteger stackAddress_;
}

@property (nonatomic, readonly) NSString *text;
@property (nonatomic, assign) NSObject<CDRExampleParent> *parent;
@property (nonatomic, assign, getter=isFocused) BOOL focused;
@property (nonatomic) NSUInteger stackAddress;

- (id)initWithText:(NSString *)text;

- (void)run;
- (BOOL)shouldRun;

- (BOOL)hasChildren;
- (BOOL)hasFocusedExamples;

- (NSString *)message;
- (NSString *)fullText;
- (NSMutableArray *)fullTextInPieces;
@end

@interface CDRExampleBase (RunReporting)
- (CDRExampleState)state;
- (NSTimeInterval)runTime;
- (float)progress;
@end
