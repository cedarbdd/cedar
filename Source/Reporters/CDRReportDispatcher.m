#import "CDRReportDispatcher.h"
#import "CDRExampleGroup.h"

@interface CDRReportDispatcher ()
@property (strong, nonatomic) CDRSpec *currentSpec;
@end

@implementation CDRReportDispatcher

@synthesize currentSpec = currentSpec_;

+ (instancetype)dispatcherWithReporters:(NSArray *)reporters {
    return [[[self alloc] initWithReporters:reporters] autorelease];
}

- (void)dealloc {
    [reporters_ release];
    reporters_ = nil;
    self.currentSpec = nil;
    [super dealloc];
}

- (id)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithReporters:(NSArray *)reporters {
    self = [super init];
    if (self) {
        reporters_ = [reporters copy];
    }
    return self;
}

#pragma mark - Public

- (void)runWillStartWithGroups:(NSArray *)groups andRandomSeed:(unsigned int)seed {
    for (id<CDRExampleReporter> reporter in reporters_) {
        [reporter runWillStartWithGroups:groups andRandomSeed:seed];
    }
}

- (void)runDidComplete {
    [self setCurrentSpecAndNotifyIfNeeded:nil];
    for (id<CDRExampleReporter> reporter in reporters_) {
        [reporter runDidComplete];
    }
}

- (int)result {
    int result = 0;
    for (id<CDRExampleReporter> reporter in reporters_) {
        result |= [reporter result];
    }
    return result;
}

- (void)runWillStartExampleGroup:(CDRExampleGroup *)exampleGroup {
    [self setCurrentSpecAndNotifyIfNeeded:exampleGroup.spec];
    for (id<CDRExampleReporter> reporter in reporters_) {
        if ([reporter respondsToSelector:@selector(runWillStartExampleGroup:)]) {
            [reporter runWillStartExampleGroup:exampleGroup];
        }
    }
}

- (void)runDidFinishExampleGroup:(CDRExampleGroup *)exampleGroup {
    [self setCurrentSpecAndNotifyIfNeeded:exampleGroup.spec];
    for (id<CDRExampleReporter> reporter in reporters_) {
        if ([reporter respondsToSelector:@selector(runDidFinishExampleGroup:)]) {
            [reporter runDidFinishExampleGroup:exampleGroup];
        }
    }
}

- (void)runWillStartExample:(CDRExample *)example {
    for (id<CDRExampleReporter> reporter in reporters_) {
        if ([reporter respondsToSelector:@selector(runWillStartExample:)]) {
            [reporter runWillStartExample:example];
        }
    }
}

- (void)runDidFinishExample:(CDRExample *)example {
    for (id<CDRExampleReporter> reporter in reporters_) {
        if ([reporter respondsToSelector:@selector(runDidFinishExample:)]) {
            [reporter runDidFinishExample:example];
        }
    }
}

- (void)runWillStartSpec:(CDRSpec *)spec {
    for (id<CDRExampleReporter> reporter in reporters_) {
        if ([reporter respondsToSelector:@selector(runWillStartSpec:)]) {
            [reporter runWillStartSpec:spec];
        }
    }
}

- (void)runDidFinishSpec:(CDRSpec *)spec {
    for (id<CDRExampleReporter> reporter in reporters_) {
        if ([reporter respondsToSelector:@selector(runDidFinishSpec:)]) {
            [reporter runDidFinishSpec:spec];
        }
    }
}

#pragma mark - Private Properties

- (void)setCurrentSpecAndNotifyIfNeeded:(CDRSpec *)currentSpec {
    if (currentSpec == self.currentSpec) {
        return;
    }
    if (self.currentSpec) {
        [self runDidFinishSpec:self.currentSpec];
    }
    self.currentSpec = currentSpec;
    if (currentSpec) {
        [self runWillStartSpec:self.currentSpec];
    }
}

@end
