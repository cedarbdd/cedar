#import "ObjectWithCollections.h"

@implementation ObjectWithCollections

-(instancetype) init {
    if (self = [super init]) {
        self.array = [NSMutableArray array];
        self.set = [NSMutableSet set];
        self.orderedSet = [NSMutableOrderedSet orderedSet];
    }

    return self;
}

- (void) mutateObservedProperty {
    [[self mutableArrayValueForKey:@"array"] addObject:@"mutations are cool"];
    [[self mutableSetValueForKey:@"set"] addObject:@"mutations are cool"];
    [[self mutableOrderedSetValueForKey:@"orderedSet"] addObject:@"mutations are cool"];

    [[self mutableArrayValueForKeyPath:@"array"] addObject:@"jinkies!"];
    [[self mutableSetValueForKeyPath:@"set"] addObject:@"mutate all the key paths"];
    [[self mutableOrderedSetValueForKeyPath:@"orderedSet"] addObject:@"in your tests, mutating your sets"];
}

@end
