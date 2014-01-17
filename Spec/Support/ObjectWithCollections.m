#import "ObjectWithCollections.h"

@implementation ObjectWithCollections

- (instancetype)init {
    if (self = [super init]) {
        self.array = [NSMutableArray array];
        self.set = [NSMutableSet set];
        self.orderedSet = [NSMutableOrderedSet orderedSet];
        self.manualArray = [NSMutableArray array];
        self.manualSet = [NSMutableSet set];
    }

    return self;
}

- (void)dealloc {
    self.array = nil;
    self.set = nil;
    self.orderedSet = nil;
    self.manualArray = nil;
    self.manualSet = nil;
    [super dealloc];
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    BOOL automatic;
    if ([key isEqualToString:@"manualArray"]) {
        automatic = NO;
    } else {
        automatic = [super automaticallyNotifiesObserversForKey:key];
    }
    return automatic;
}

- (void) mutateObservedProperty {
    [[self mutableArrayValueForKey:@"array"] addObject:@"mutations are cool"];
    [[self mutableSetValueForKey:@"set"] addObject:@"mutations are cool"];
    [[self mutableOrderedSetValueForKey:@"orderedSet"] addObject:@"mutations are cool"];

    [[self mutableArrayValueForKeyPath:@"array"] addObject:@"jinkies!"];
    [[self mutableSetValueForKeyPath:@"set"] addObject:@"mutate all the key paths"];
    [[self mutableOrderedSetValueForKeyPath:@"orderedSet"] addObject:@"in your tests, mutating your sets"];


    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];

    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexSet forKey:@"manualArray"];
    [self.manualArray addObject:@"testing all the things"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexSet forKey:@"manualArray"];

    NSSet *changeObjects = [NSSet setWithObjects:@"testing all the things", nil];
    [self willChangeValueForKey:@"manualSet" withSetMutation:NSKeyValueSetSetMutation usingObjects:changeObjects];
    [self.manualSet addObject:[[changeObjects allObjects] objectAtIndex:0]];
    [self didChangeValueForKey:@"manualSet" withSetMutation:NSKeyValueSetSetMutation usingObjects:changeObjects];
}

@end
