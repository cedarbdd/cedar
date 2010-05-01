#import <Foundation/Foundation.h>

@protocol CDRExampleRunner;

typedef void (^CDRSpecBlock)(void);

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
- (void)runWithRunner:(id<CDRExampleRunner>)runner;

@end
