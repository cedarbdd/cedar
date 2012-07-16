#import "NoOpKeyValueObserver.h"

@implementation NoOpKeyValueObserver

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
}

@end

