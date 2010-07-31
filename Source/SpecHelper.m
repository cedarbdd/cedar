#import "SpecHelper.h"

static SpecHelper *specHelper__;

@implementation SpecHelper

+ (id)specHelper {
    if (!specHelper__) {
        specHelper__ = [[SpecHelper alloc] init];
    }
    return specHelper__;
}

- (id)init {
    if (self = [super init]) {
        sharedExampleGroups_ = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    [sharedExampleGroups_ release];
    [super dealloc];
}

- (void)beforeEach {
}

- (void)afterEach {
}

#pragma mark CDRExampleParent
- (void)setUp {
    [self beforeEach];
}

- (void)tearDown {
    [self afterEach];
}

@end
