#import <Foundation/Foundation.h>

@protocol CDRExampleRunner;

typedef void (^CDRSpecBlock)(void);

enum CDRExampleState {
    CDRExampleStateIncomplete = 0x00,
    CDRExampleStatePassed = 0x01,
    CDRExampleStatePending = 0x03,
    CDRExampleStateFailed = 0x07,
    CDRExampleStateError = 0x0F
};
typedef enum CDRExampleState CDRExampleState;

@interface CDRSpecFailure : NSException
+ (id)specFailureWithReason:(NSString *)reason;
@end

@interface CDRExampleBase : NSObject {
  NSString *text_;
  CDRExampleBase *parent_;
}

@property (nonatomic, readonly) NSString *text;
@property (nonatomic, assign) CDRExampleBase *parent;

- (id)initWithText:(NSString *)text;

- (void)setUp;
- (void)tearDown;
- (void)runWithRunner:(id<CDRExampleRunner>)runner;
- (BOOL)hasChildren;
- (NSString *)fullText;
@end

@interface CDRExampleBase (RunReporting)
- (CDRExampleState)state;
- (float)progress;
- (void)stateDidChange;
@end
