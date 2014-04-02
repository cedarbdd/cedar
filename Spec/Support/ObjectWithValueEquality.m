#import "ObjectWithValueEquality.h"

@implementation ObjectWithValueEquality {
    NSInteger _integer;
}

- (instancetype)initWithInteger:(NSInteger)integer {
    if (self = [super init]) {
        _integer = integer;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[ObjectWithValueEquality class]] && ((ObjectWithValueEquality *)object)->_integer == _integer;
}

- (NSUInteger)hash {
    return [@(_integer) hash];
}

@end
