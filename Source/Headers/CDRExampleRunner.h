#import <Foundation/Foundation.h>

@class CDRExample;

@protocol CDRExampleRunner <NSObject>

@required
- (void)exampleSucceeded:(CDRExample *)example;
- (void)example:(CDRExample *)example failedWithMessage:(NSString *)message;
- (void)example:(CDRExample *)example threwException:(NSException *)exception;
- (void)exampleThrewError:(CDRExample *)example;
- (void)examplePending:(CDRExample *)example;
- (int)result;

@optional
- (void)runWillStartWithSpecs:(NSArray *)specs;

@end
