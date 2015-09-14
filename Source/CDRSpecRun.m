#import "CDRSpecRun.h"
#import "CDRSpec.h"
#import "CDRPrivateFunctions.h"
#import "CDRReportDispatcher.h"

@implementation CDRSpecRun

- (instancetype)initWithExampleReporters:(NSArray *)reporters {
    if (self = [super init]) {
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

- (void)dealloc {
    [_specs release]; _specs = nil;
    [_rootGroups release]; _rootGroups = nil;
    [_dispatcher release]; _dispatcher = nil;
    [super dealloc];
}

- (int)performSpecRun:(void (^)(void))runBlock {
    [self.dispatcher runWillStartWithGroups:self.rootGroups andRandomSeed:self.seed];

    runBlock();

    [self.dispatcher runDidComplete];

    return [self.dispatcher result];
}

@end
