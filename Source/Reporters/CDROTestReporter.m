#import "CDROTestReporter.h"
#import "CDRPrivateFunctions.h"
#import "CDRExample.h"
#import "CDRExampleGroup.h"
#import "CDRSpecHelper.h"
#import "CDRSpec.h"
#import "CDROTestNamer.h"

@interface CDROTestReporter ()
@property (retain, nonatomic) NSString *cedarVersionString;

@property (retain, nonatomic) NSDate *startTime;
@property (retain, nonatomic) NSDate *endTime;
@property (retain, nonatomic) NSDateFormatter *formatter;
@property (retain, nonatomic) CDROTestNamer *namer;

@property (retain, nonatomic) NSString *currentMethodName;
@property (retain, nonatomic) NSString *currentSuiteName;
@property (retain, nonatomic) CDRExampleGroup *currentSuite;

@property (retain, nonatomic) NSArray *rootGroups;
@property (assign, nonatomic) NSUInteger failedCount;
@end

@implementation CDROTestReporter

- (void)dealloc {
    self.cedarVersionString = nil;
    self.startTime = nil;
    self.endTime = nil;
    self.formatter = nil;
    self.currentSuiteName = nil;
    self.currentSuite = nil;
    self.rootGroups = nil;
    self.namer = nil;
    [super dealloc];
}

- (instancetype)initWithCedarVersion:(NSString *)cedarVersionString {
    self = [super init];
    if (self) {
        self.formatter = [[[NSDateFormatter alloc] init] autorelease];
        [self.formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss Z"];
        self.namer = [[[CDROTestNamer alloc] init] autorelease];
        self.cedarVersionString = cedarVersionString;
    }
    return self;
}

#pragma mark - <CDRExampleReporter>

- (void)runWillStartWithGroups:(NSArray *)groups andRandomSeed:(unsigned int)seed {
    self.startTime = [NSDate date];
    self.rootGroups = groups;

    [self logMessage:[NSString stringWithFormat:@"Cedar Version: %@", self.cedarVersionString]];
    [self logMessage:[NSString stringWithFormat:@"Cedar Random Seed: %d", seed]];

    [self startSuite:[self rootSuiteName] atDate:self.startTime];
    [self startSuite:[self bundleSuiteName] atDate:self.startTime];
}

- (void)runDidComplete {
    if (self.currentSuiteName) {
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

- (void)runWillStartExampleGroup:(CDRExampleGroup *)exampleGroup {}
- (void)runDidFinishExampleGroup:(CDRExampleGroup *)exampleGroup {}

- (void)runWillStartExample:(CDRExample *)example {
    if ([self shouldReportExample:example]) {
        NSString *testSuite = [self.namer classNameForExample:example];
        NSString *methodName = [self.namer methodNameForExample:example];
        self.currentMethodName = methodName;
        [self logMessage:[NSString stringWithFormat:@"Test Case '-[%@ %@]' started.", testSuite, methodName]];
    }
}

- (void)runDidFinishExample:(CDRExample *)example {
    if ([self shouldReportExample:example]) {
        NSString *testSuite = [self.namer classNameForExample:example];
        NSString *status = [self stateNameForExample:example];
        [self logMessage:[self stringForErrorsForExample:example
                                               suiteName:testSuite
                                                caseName:self.currentMethodName]];
        [self logMessage:[NSString stringWithFormat:@"Test Case '-[%@ %@]' %@ (%.3f seconds).\n",
                          testSuite, self.currentMethodName, status, example.runTime]];
    }
}

- (void)runWillStartSpec:(CDRSpec *)spec {
    if ([self shouldReportSpec:spec]) {
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
    return [CDRSpecHelper specHelper].shouldOnlyRunFocused;
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
    NSBundle *testBundle = CDRBundleContainingSpecs();
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

- (NSString *)stringForErrorsForExample:(CDRExample *)example
                              suiteName:(NSString *)suiteName
                               caseName:(NSString *)caseName {
    if (example.failure) {
        NSString *errorDescription = [example.failure.reason stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        NSString *errorMessage = [NSString stringWithFormat:@"%@:%d: error: -[%@ %@] : %@",
                                  example.failure.fileName, example.failure.lineNumber,
                                  suiteName, caseName,
                                  errorDescription];
        return errorMessage;
    } else {
        return @"";
    }
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
