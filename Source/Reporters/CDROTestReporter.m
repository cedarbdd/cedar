#import "CDROTestReporter.h"
#import "CDRFunctions.h"
#import "CDRExample.h"
#import "CDRExampleGroup.h"
#import "SpecHelper.h"
#import "CDRSpec.h"
#import "CDROTestNamer.h"

@interface CDROTestReporter ()
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) CDROTestNamer *namer;

@property (strong, nonatomic) NSString *currentSuiteName;
@property (strong, nonatomic) CDRExampleGroup *currentSuite;

@property (strong, nonatomic) NSArray *rootGroups;
@property (assign, nonatomic) NSUInteger failedCount;
@end

@implementation CDROTestReporter

- (void)dealloc {
    self.startTime = nil;
    self.endTime = nil;
    self.formatter = nil;
    self.currentSuiteName = nil;
    self.currentSuite = nil;
    self.rootGroups = nil;
    self.namer = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        self.formatter = [[[NSDateFormatter alloc] init] autorelease];
        [self.formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss Z"];
        self.namer = [[CDROTestNamer alloc] init];
    }
    return self;
}

#pragma mark - <CDRExampleReporter>

- (void)runWillStartWithGroups:(NSArray *)groups andRandomSeed:(unsigned int)seed {
    self.startTime = [NSDate date];
    self.rootGroups = groups;

    [self logMessage:[NSString stringWithFormat:@"Cedar Random Seed: %d", seed]];

    [self startSuite:[self rootSuiteName] atDate:self.startTime];
    [self startSuite:[self bundleSuiteName] atDate:self.startTime];
}

- (void)runDidComplete {
    if (self.currentSuiteName){
        [self finishSuite:self.currentSuiteName atDate:[NSDate date]];
        [self printStatsForExamples:@[self.currentSuite]];
    }
    self.endTime = [NSDate date];

    [self finishSuite:[self bundleSuiteName] atDate:self.endTime];
    [self printStatsForExamples:self.rootGroups];
    [self finishSuite:[self rootSuiteName] atDate:self.endTime];
    [self printStatsForExamples:self.rootGroups];
}

- (int)result {
    if ([self isFocused] || self.failedCount) {
        return 1;
    } else {
        return 0;
    }
}

#pragma mark Optional Methods

- (void)runWillStartExample:(CDRExample *)example {
    if ([self shouldReportExample:example]) {
        NSString *testSuite = [self.namer classNameForExample:example];
        NSString *methodName = [self.namer methodNameForExample:example];
        [self logMessage:[NSString stringWithFormat:@"Test Case '-[%@ %@]' started.", testSuite, methodName]];
    }
}

- (void)runDidFinishExample:(CDRExample *)example {
    if ([self shouldReportExample:example]) {
        NSString *testSuite = [self.namer classNameForExample:example];
        NSString *methodName = [self.namer methodNameForExample:example];
        NSString *status = [self stateNameForExample:example];
        [self logMessage:[NSString stringWithFormat:@"Test Case '-[%@ %@]' %@ (%.3f seconds).\n",
                          testSuite, methodName, status, example.runTime]];
    }
}

- (void)runWillStartSpec:(CDRSpec *)spec {
    if ([self shouldReportSpec:spec]){
        [self startSuite:NSStringFromClass([spec class]) atDate:[NSDate date]];
    }
}

- (void)runDidFinishSpec:(CDRSpec *)spec {
    if ([self shouldReportSpec:spec]) {
        [self finishSuite:NSStringFromClass([spec class]) atDate:[NSDate date]];
        [self printStatsForExamples:@[spec.rootGroup]];
    }
}

#pragma mark - Protected

- (void)logMessage:(NSString *)message {
    fprintf(stderr, "%s\n", message.UTF8String);
}

#pragma mark - Private

- (BOOL)isFocused {
    return [SpecHelper specHelper].shouldOnlyRunFocused;
}

- (NSString *)rootSuiteName {
    return [self isFocused] ? @"Multiple Selected Tests" : @"All tests";
}

- (BOOL)shouldReportExample:(CDRExample *)example {
    BOOL isNotSkippedOrPending = !example.shouldRun || !example.isPending;
    return isNotSkippedOrPending && (![self isFocused] || example.isFocused);
}

- (BOOL)shouldReportSpec:(CDRSpec *)spec {
    return ![self isFocused] || spec.rootGroup.hasFocusedExamples;
}

- (NSString *)bundleSuiteName {
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    return testBundle.bundleURL.pathComponents.lastObject;
}

- (void)startSuite:(NSString *)name atDate:(NSDate *)date {
    NSString *format = [self.formatter stringFromDate:date];
    [self logMessage:[NSString stringWithFormat:@"Test Suite '%@' started at %@.", name, format]];
}

- (void)finishSuite:(NSString *)name atDate:(NSDate *)date {
    NSString *format = [self.formatter stringFromDate:date];
    [self logMessage:[NSString stringWithFormat:@"Test Suite '%@' finished at %@.", name, format]];
}

- (NSString *)stateNameForExample:(CDRExample *)example {
    switch (example.state) {
        case CDRExampleStatePassed:
            return @"passed";
        case CDRExampleStateFailed:
        case CDRExampleStateError:
            return @"failed";
        case CDRExampleStatePending:
        case CDRExampleStateSkipped:
        case CDRExampleStateIncomplete:
            return nil;
    }
}

- (NSString *)recordFailedExample:(CDRExample *)example
                        suiteName:(NSString *)suiteName
                         caseName:(NSString *)caseName {
    NSString *errorDescription = [example.failure.reason stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    NSString *errorMessage = [NSString stringWithFormat:@"%@:%d: error: -[%@ %@] : %@",
                              example.failure.fileName, example.failure.lineNumber,
                              suiteName, caseName,
                              errorDescription];
    return errorMessage;
}

- (void)printStatsForExamples:(NSArray *)examples {
    NSDictionary *stats = [self statsForExamples:examples];
    NSUInteger count = [[stats objectForKey:@"count"] unsignedIntegerValue];
    NSUInteger failed = [[stats objectForKey:@"failed"] unsignedIntegerValue];
    NSUInteger unexpected = [[stats objectForKey:@"unexpected"] unsignedIntegerValue];
    const char *testsString = (count == 1 ? "test" : "tests");
    const char *failuresString = (failed == 1 ? "failure" : "failures");
    float totalTimeElapsed = [self.endTime timeIntervalSinceDate:self.startTime];

    [self logMessage:[NSString stringWithFormat:
                      @"Executed %lu %s, with %lu %s (%lu unexpected) in %.4f (%.4f) seconds",
                      (unsigned long)count, testsString,
                      (unsigned long)failed, failuresString,
                      (unsigned long)unexpected,
                      totalTimeElapsed, totalTimeElapsed]];
}

- (NSDictionary *)statsForExamples:(NSArray *)examples {
    NSUInteger count = 0;
    NSUInteger unexpected = 0;
    NSUInteger failed = 0;
    for (id example in examples) {
        if (![example hasChildren]) {
            if (![example isKindOfClass:[CDRExampleGroup class]]) {
                count += ([self stateNameForExample:example] != nil);
                CDRExampleState state = ((CDRExample *)example).state;
                unexpected += (state == CDRExampleStateError);
                failed += (state == CDRExampleStateFailed);
            }
        } else {
            NSDictionary *stats = [self statsForExamples:[example examples]];
            count += [[stats objectForKey:@"count"] unsignedIntegerValue];
            unexpected += [[stats objectForKey:@"unexpected"] unsignedIntegerValue];
            failed += [[stats objectForKey:@"failed"] unsignedIntegerValue];
        }
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedInteger:count], @"count",
            [NSNumber numberWithUnsignedInteger:unexpected], @"unexpected",
            [NSNumber numberWithUnsignedInteger:failed], @"failed", nil];
}

@end
