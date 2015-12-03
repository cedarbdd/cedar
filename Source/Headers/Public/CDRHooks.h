#import <Foundation/Foundation.h>

/**
 * CDRHooks
 *
 * Use this protocol when you want to register a class for global beforeEach and afterEach blocks.
 */
@protocol CDRHooks <NSObject>

@optional

+ (void)beforeEach;
+ (void)afterEach;

@end
