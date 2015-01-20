#import "CDRNil.h"

@implementation CDRNil

+ (instancetype)nilObject {
    return [[[self alloc] init] autorelease];
}

- (BOOL)isEqual:(id)object {
    return object==self || [object isMemberOfClass:[self class]];
}

- (NSString *)description {
    return @"<nil>";
}

- (id)copyWithZone:(NSZone *)zone {
    return [self retain];
}

@end
