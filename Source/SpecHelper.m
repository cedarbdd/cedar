#import "SpecHelper.h"

SpecHelper *specHelper;

@implementation SpecHelper

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
