#import "SpecHelper.h"

SpecHelper *specHelper;

@implementation SpecHelper

+ (void)initialize {
    specHelper = [[SpecHelper alloc] init];
}

+ (id)specHelper {
    return specHelper;
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
