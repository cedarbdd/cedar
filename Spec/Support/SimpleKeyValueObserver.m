#import "SimpleKeyValueObserver.h"

@interface SimpleKeyValueObserver ()
@property (nonatomic, copy, readwrite) NSString *lastObservedKeyPath;
@end

@implementation SimpleKeyValueObserver

- (void)dealloc {
    self.lastObservedKeyPath = nil;
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.lastObservedKeyPath = keyPath;
}

@end
