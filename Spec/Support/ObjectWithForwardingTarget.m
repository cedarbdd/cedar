#import "ObjectWithForwardingTarget.h"

@interface ObjectWithForwardingTarget ()
@property (nonatomic, retain) NSArray *things;
@end

@implementation ObjectWithForwardingTarget

- (id)initWithNumberOfThings:(NSUInteger)count {
    self = [super init];
    if (self) {
        NSMutableArray *mutableThings = [NSMutableArray arrayWithCapacity:count];
        for (NSUInteger i = 0; i < count; i++) {
            [mutableThings addObject:[[[NSObject alloc] init] autorelease]];
        }
        self.things = [NSArray arrayWithArray:mutableThings];
    }
    return self;
}

- (void)dealloc {
    self.things = nil;
    [super dealloc];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector] || [self.things respondsToSelector:aSelector] || aSelector == @selector(unforwardedUnimplementedMethod);
}

+ (BOOL)instancesRespondToSelector:(SEL)aSelector {
    return [super instancesRespondToSelector:aSelector] || [[NSArray class] instancesRespondToSelector:aSelector] || aSelector == @selector(unforwardedUnimplementedMethod);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *ownSignature = [super methodSignatureForSelector:aSelector];
    return ownSignature ? ownSignature : [self.things methodSignatureForSelector:aSelector];
}

+ (NSMethodSignature *)instanceMethodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *ownSignature = [super instanceMethodSignatureForSelector:aSelector];
    return ownSignature ? ownSignature : [[NSArray class] instanceMethodSignatureForSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return [self.things respondsToSelector:aSelector] ? self.things : [super forwardingTargetForSelector:aSelector];
}

- (void)updateWithValue:(NSUInteger)value {

}

@end
