#import <Foundation/Foundation.h>

@protocol CDRExampleRunner;

typedef void (^CDRSpecBlock)(void);

enum CDRExampleState {
    CDRExampleStateIncomplete = 0,
    CDRExampleStatePassed,
    CDRExampleStateFailed,
    CDRExampleStateError,
    CDRExampleStatePending
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
@property (nonatomic, readonly) CDRExampleState state;

- (id)initWithText:(NSString *)text;

- (void)setUp;
- (void)tearDown;
- (void)runWithRunner:(id<CDRExampleRunner>)runner;

@end
