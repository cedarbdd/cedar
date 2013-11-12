#import <Foundation/Foundation.h>

@interface SimpleKeyValueObserver : NSObject

@property (nonatomic, copy, readonly) NSString *lastObservedKeyPath;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

@end
