#import <Foundation/Foundation.h>

/**
 * CDRNil is an internal class used to box 'nil' values when they need to be put into a 
 * Cocoa collection. This is needed beside NSNull to allow differentiating between usages
 * of NSNull and true nils.
 */
@interface CDRNil : NSObject <NSCopying>

+ (instancetype)nilObject;

@end
