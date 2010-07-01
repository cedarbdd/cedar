#import "SpecHelper.h"

SpecHelper *specHelper;

@implementation SpecHelper

+ (void)initialize {
    specHelper = [[SpecHelper alloc] init];
}

+ (id)specHelper {
    return specHelper;
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
