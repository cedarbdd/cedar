#import "CDROTestReporter.h"
#import "CDRFunctions.h"
#import "CDRExample.h"
#import "CDRExampleGroup.h"
#import "SpecHelper.h"
#import "CDRSpec.h"

@interface CDROTestReporter ()
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;
@property (strong, nonatomic) NSDateFormatter *formatter;

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
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        self.formatter = [[[NSDateFormatter alloc] init] autorelease];
        [self.formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss Z"];
    }
    return self;
}

#pragma mark - <CDRExampleReporter>

- (void)runWillStartWithGroups:(NSArray *)groups andRandomSeed:(unsigned int)seed {
    self.startTime = [NSDate date];
    self.rootGroups = groups;

    [self logMessage:[NSString stringWithFormat:@"Cedar Random Seed: %d", seed]];

    [self startSuite:@"Cedar Tests" atDate:self.startTime];
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
    [self finishSuite:@"Cedar Tests" atDate:self.endTime];
    [self printStatsForExamples:self.rootGroups];
}

- (int)result {
    if ([SpecHelper specHelper].shouldOnlyRunFocused || self.failedCount) {
        return 1;
    } else {
        return 0;
    }
}

#pragma mark Optional Methods

- (void)runWillStartExample:(CDRExample *)example {
    NSString *testSuite = [self classNameForExample:example];
    NSString *methodName = [self methodNameForExample:example];
    [self logMessage:[NSString stringWithFormat:@"Test Case '-[%@ %@]' started.", testSuite, methodName]];
}

- (void)runDidFinishExample:(CDRExample *)example {
    NSString *testSuite = [self classNameForExample:example];
    NSString *methodName = [self methodNameForExample:example];
    NSString *status = [self stateNameForExample:example];

    [self logMessage:[NSString stringWithFormat:@"Test Case '-[%@ %@]' %@ (%.3f seconds).\n",
                      testSuite, methodName, status, example.runTime]];
}

- (void)runWillStartSpec:(CDRSpec *)spec {
    [self startSuite:NSStringFromClass([spec class]) atDate:[NSDate date]];
}

- (void)runDidFinishSpec:(CDRSpec *)spec {
    [self finishSuite:NSStringFromClass([spec class]) atDate:[NSDate date]];
    [self printStatsForExamples:@[spec.rootGroup]];
}

#pragma mark - Protected

- (void)logMessage:(NSString *)message {
    fprintf(stderr, "%s\n", message.UTF8String);
}

#pragma mark - Private

- (BOOL)shouldReportExample:(CDRExample *)example {
    return example.state == CDRExampleStateSkipped || example.state == CDRExampleStatePending;
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

- (NSString *)sanitizedStringFromString:(NSString *)string {
    NSMutableString *mutableString = [string mutableCopy];
    [mutableString replaceOccurrencesOfString:@" " withString:@"_" options:0 range:NSMakeRange(0, mutableString.length)];

    NSMutableCharacterSet *allowedCharacterSet = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
    [allowedCharacterSet addCharactersInString:@"_"];

    for (NSUInteger i=0; i<mutableString.length; i++) {
        if (![allowedCharacterSet characterIsMember:[mutableString characterAtIndex:i]]) {
            [mutableString deleteCharactersInRange:NSMakeRange(i, 1)];
            i--;
        }
    }
    return mutableString;
}

- (NSString *)classNameForExample:(CDRExample *)example {
    NSString *className = NSStringFromClass([example.spec class]);
    return [self sanitizedStringFromString:className];
}

- (NSString *)methodNameForExample:(CDRExample *)example {
    NSMutableArray *fullTextPieces = [example.fullTextInPieces mutableCopy];
    NSString *specClassName = [self classNameForExample:example];
    NSString *firstPieceWithSpecPostfix = [NSString stringWithFormat:@"%@Spec", [fullTextPieces objectAtIndex:0]];
    if ([firstPieceWithSpecPostfix isEqual:specClassName]) {
        [fullTextPieces removeObjectAtIndex:0];
    }

    NSString *methodName = [fullTextPieces componentsJoinedByString:@"_"];
    return [self sanitizedStringFromString:methodName];
}

- (NSString *)stateNameForExample:(CDRExample *)example {
    switch (example.state) {
        case CDRExampleStatePassed:
            return @"passed";
        case CDRExampleStatePending:
            return @"pending";
        case CDRExampleStateSkipped:
            return @"skipped";
        case CDRExampleStateFailed:
        case CDRExampleStateError:
            return @"failed";
        case CDRExampleStateIncomplete:
            return @"incomplete";
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
                ++count;
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
