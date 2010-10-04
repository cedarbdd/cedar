#import "SpecHelper.h"

@interface SpecHelper ()
@property (nonatomic, retain, readwrite) NSMutableDictionary *sharedExampleGroups, *sharedExampleContext;
@end

static SpecHelper *specHelper__;

@implementation SpecHelper

@synthesize sharedExampleGroups = sharedExampleGroups_, sharedExampleContext = sharedExampleContext_;

+ (id)specHelper {
    if (!specHelper__) {
        specHelper__ = [[SpecHelper alloc] init];
    }
    return specHelper__;
}

- (id)init {
    if (self = [super init]) {
        self.sharedExampleGroups = [NSMutableDictionary dictionary];
        self.sharedExampleContext = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    self.sharedExampleGroups = nil;
    self.sharedExampleContext = nil;
    [super dealloc];
}

- (void)beforeEach {
}

- (void)afterEach {
}

#pragma mark CDRExampleParent
- (void)setUp {
    [self.sharedExampleContext removeAllObjects];
    [self beforeEach];
}

- (void)tearDown {
    [self afterEach];
}

@end
