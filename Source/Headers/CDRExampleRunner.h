#import <Foundation/Foundation.h>

@class CDRExample;

@protocol CDRExampleRunner <NSObject>

- (void)exampleSucceeded:(CDRExample *)example;
- (void)example:(CDRExample *)example failedWithMessage:(NSString *)message;
- (void)example:(CDRExample *)example threwException:(NSException *)exception;
- (void)exampleThrewError:(CDRExample *)example;
- (int)result;

@end
