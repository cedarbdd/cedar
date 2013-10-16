#import <Foundation/Foundation.h>

@protocol CDRHooks <NSObject>

@optional

+ (void)beforeEach;
+ (void)afterEach;

@end
