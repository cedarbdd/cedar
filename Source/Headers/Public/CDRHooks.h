#import <Foundation/Foundation.h>

/**
 * CDRHooks
 *
 * Conform classes to this protocol if you want to register global
 * beforeEach and afterEach blocks that are called for all specs
 */
@protocol CDRHooks <NSObject>

@optional

+ (void)beforeEach;
+ (void)afterEach;

@end
