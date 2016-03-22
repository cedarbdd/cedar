#import "TestReporter.h"

#if !__has_feature(objc_arc)
#error This class must be compiled with ARC.
#endif

@implementation TestReporter {
    NSMutableArray *_startedExamples;
    NSMutableArray *_finishedExamples;
    NSMutableArray *_startedExampleGroups;
    NSMutableArray *_finishedExampleGroups;
}

- (instancetype)init {
    if (self = [super init]) {
        _startedExamples = [NSMutableArray array];
        _finishedExamples = [NSMutableArray array];
        _startedExampleGroups = [NSMutableArray array];
        _finishedExampleGroups = [NSMutableArray array];
    }
    return self;
}

- (void)runWillStartWithGroups:(NSArray *)groups andRandomSeed:(unsigned int)seed {}
- (void)runDidComplete {}
- (int)result {
    return 0;
}

- (void)runWillStartExample:(CDRExample *)example {
    [_startedExamples addObject:example];
}
- (void)runDidFinishExample:(CDRExample *)example {
    [_finishedExamples addObject:example];
}

- (void)runWillStartExampleGroup:(CDRExampleGroup *)exampleGroup {
    [_startedExampleGroups addObject:exampleGroup];
}
- (void)runDidFinishExampleGroup:(CDRExampleGroup *)exampleGroup {
    [_finishedExampleGroups addObject:exampleGroup];
}

- (void)runWillStartSpec:(CDRSpec *)spec {}
- (void)runDidFinishSpec:(CDRSpec *)spec {}

@end
