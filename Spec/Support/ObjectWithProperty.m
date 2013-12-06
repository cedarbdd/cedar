#import "ObjectWithProperty.h"

@implementation ObjectWithProperty

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    BOOL automatic;
    if ([key isEqualToString:@"manualFloatProperty"]) {
        automatic = NO;
    } else {
        automatic = [super automaticallyNotifiesObserversForKey:key];
    }
    return automatic;
}

- (void) mutateObservedProperty {
    self.floatProperty = 12;

    [self willChangeValueForKey:@"manualFloatProperty"];
    self.manualFloatProperty = 21;
    [self didChangeValueForKey:@"manualFloatProperty"];
}

@end
