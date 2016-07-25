#import "CDRSpec.h"
#import "CDRSpecRun.h"
#import "CDRPrivateFunctions.h"
#import "CDRReportDispatcher.h"

@interface CDRSpecRun ()
@property (nonatomic, retain) id<CDRStateTracking> stateTracker;
@end

@implementation CDRSpecRun

- (instancetype)initWithStateTracker:(id<CDRStateTracking>)stateTracker
                    exampleReporters:(NSArray *)reporters {
    if (self = [super init]) {
        _stateTracker = [stateTracker retain];
        [_stateTracker didStartPreparingTests];

        CDRDefineSharedExampleGroups();
        CDRDefineGlobalBeforeAndAfterEachBlocks();

        _seed = CDRGetRandomSeed();

        NSArray *specClasses = CDRSpecClassesToRun();
        NSArray *permutedSpecClasses = CDRPermuteSpecClassesWithSeed(specClasses, _seed);
        _specs = [CDRSpecsFromSpecClasses(permutedSpecClasses) retain];
        CDRMarkFocusedExamplesInSpecs(_specs);
        CDRMarkXcodeFocusedExamplesInSpecs(_specs, [[NSProcessInfo processInfo] arguments]);

        _dispatcher = [[CDRReportDispatcher alloc] initWithReporters:reporters];
        _rootGroups = [[_specs valueForKey:NSStringFromSelector(@selector(rootGroup))] retain];
    }
    return self;
}

- (int)performSpecRun:(void (^)(void))runBlock {
    [self.stateTracker didStartRunningTests];
    [self.dispatcher runWillStartWithGroups:self.rootGroups andRandomSeed:self.seed];

    runBlock();

    [self.dispatcher runDidComplete];

    [self.stateTracker didFinishRunningTests];
    return [self.dispatcher result];
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)dealloc {
    [_specs release]; _specs = nil;
    [_rootGroups release]; _rootGroups = nil;
    [_dispatcher release]; _dispatcher = nil;
    [_stateTracker release]; _stateTracker = nil;
    [super dealloc];
}

@end
