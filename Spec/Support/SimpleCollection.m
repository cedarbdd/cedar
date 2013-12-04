#import "SimpleCollection.h"

@implementation SimpleCollection

-(instancetype) init {
    if (self = [super init]) {
        self.collection = [NSMutableArray array];
    }

    return self;
}

- (void) mutateCollection {
    [[self mutableArrayValueForKey:@"collection"] addObject:@"mutations are cool"];
}

@end
