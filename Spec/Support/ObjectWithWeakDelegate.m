#import "ObjectWithWeakDelegate.h"

#if !__has_feature(objc_arc)
#error This class must be compiled with ARC to work properly with the spec that uses it
#endif

@implementation ObjectWithWeakDelegate

- (void)tellTheDelegate {
    [self.delegate someMessage];
}

@end
