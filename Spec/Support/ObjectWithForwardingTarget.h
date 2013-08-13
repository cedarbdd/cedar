#import <Foundation/Foundation.h>

@interface ObjectWithForwardingTarget : NSObject

- (id)initWithNumberOfThings:(NSUInteger)count;

- (void)updateWithValue:(NSUInteger)value;

@end

@interface ObjectWithForwardingTarget (Forwarded)

- (NSUInteger)count;
- (void)unforwardedUnimplementedMethod;

@end
