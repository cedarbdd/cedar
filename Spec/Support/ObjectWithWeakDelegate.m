#import "ObjectWithWeakDelegate.h"

@implementation ObjectWithWeakDelegate

- (void)tellTheDelegate {
    [self.delegate someMessage];
}

@end
