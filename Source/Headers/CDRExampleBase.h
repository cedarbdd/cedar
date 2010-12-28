#import <Foundation/Foundation.h>

@protocol CDRExampleReporter;

typedef void (^CDRSpecBlock)(void);

enum _CDRExampleState {
    CDRExampleStateIncomplete = 0x00,
    CDRExampleStatePassed     = 0x01,
    CDRExampleStatePending    = 0x03,
    CDRExampleStateFailed     = 0x07,
    CDRExampleStateError      = 0x0F
};
typedef NSUInteger CDRExampleState;

@interface CDRSpecFailure : NSException
+ (id)specFailureWithReason:(NSString *)reason;
@end

@class CDRExampleGroup;

@interface CDRExampleBase : NSObject
{
    NSString        *text_;
    CDRExampleGroup *parent_;
}

@property(nonatomic, readonly) NSString        *text;
@property(nonatomic, assign)   CDRExampleGroup *parent;

- (id)initWithText:(NSString *)text;

- (void)run;
- (BOOL)hasChildren;
- (NSString *)message;
- (NSString *)fullText;

@end

@interface CDRExampleBase (RunReporting)

@property(nonatomic, readonly) NSUInteger      numberOfErrors;
@property(nonatomic, readonly) NSUInteger      numberOfFailures;
@property(nonatomic, readonly) NSUInteger      numberOfPendingExamples;
@property(nonatomic, readonly) NSUInteger      numberOfSuccesses;
@property(nonatomic, readonly) NSUInteger      numberOfExamples;
@property(nonatomic, readonly) CDRExampleState state;
@property(nonatomic, readonly) float           progress;

@end
