#import "CDRSpecHelper.h"

static CDRSpecHelper *specHelper__;

@interface CDRSpecHelper ()
@property (nonatomic, retain, readwrite) NSMutableDictionary *sharedExampleGroups, *sharedExampleContext;
@end

@implementation CDRSpecHelper

@synthesize
    sharedExampleGroups = sharedExampleGroups_,
    sharedExampleContext = sharedExampleContext_,
    globalBeforeEachClasses = globalBeforeEachClasses_,
    globalAfterEachClasses = globalAfterEachClasses_,
    shouldOnlyRunFocused = shouldOnlyRunFocused_;

+ (id)specHelper {
    if (!specHelper__) {
        specHelper__ = [[CDRSpecHelper alloc] init];
    }
    return specHelper__;
}

- (id)init {
    if (self = [super init]) {
        self.sharedExampleGroups = [NSMutableDictionary dictionary];
        self.sharedExampleContext = [NSMutableDictionary dictionary];
        self.shouldOnlyRunFocused = NO;
    }
    return self;
}

- (void)dealloc {
    self.sharedExampleGroups = nil;
    self.sharedExampleContext = nil;
    self.globalBeforeEachClasses = nil;
    self.globalAfterEachClasses = nil;
    [super dealloc];
}

#pragma mark CDRExampleParent
- (BOOL)shouldRun {
    return NO;
}

- (void)setUp {
    if ([self respondsToSelector:@selector(beforeEach)]) {
        NSLog(@"********************************************************************************");
        NSLog(@"Cedar no longer runs beforeEach blocks defined on the SpecHelper class.\n");
        NSLog(@"Rather than defining a global beforeEach on the SpecHelper instance,");
        NSLog(@"declare a +beforeEach class method on a separate spec-specific class.");
        NSLog(@"This allows for more than one beforeEach without them overwriting one another.");
        NSLog(@"********************************************************************************");
    }

    [self.globalBeforeEachClasses makeObjectsPerformSelector:@selector(beforeEach)];
}

- (CDRSpecBlock)subjectActionBlock {
    return nil;
}

- (void)tearDown {
    if ([self respondsToSelector:@selector(afterEach)]) {
        NSLog(@"********************************************************************************");
        NSLog(@"Cedar no longer runs afterEach blocks defined on the SpecHelper class.\n");
        NSLog(@"Rather than defining a global afterEach on the SpecHelper instance,");
        NSLog(@"declare an +afterEach class method on a separate spec-specific class.");
        NSLog(@"This allows for more than one afterEach without them overwriting one another.");
        NSLog(@"********************************************************************************");
    }

    [self.globalAfterEachClasses makeObjectsPerformSelector:@selector(afterEach)];
    [self.sharedExampleContext removeAllObjects];
}

@end
