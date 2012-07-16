#import <Foundation/Foundation.h>

@interface NoOpKeyValueObserver : NSObject

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

@end
