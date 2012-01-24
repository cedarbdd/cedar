#import <Foundation/Foundation.h>

@interface SimpleIncrementer : NSObject

@property (nonatomic, assign) size_t value;

- (void)increment;
- (void)incrementBy:(size_t)amount;

@end
