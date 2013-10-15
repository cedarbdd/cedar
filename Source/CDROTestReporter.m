#import "CDROTestReporter.h"
#import "CDRFunctions.h"
#import "CDRExample.h"
#import "CDRExampleGroup.h"
#import "SpecHelper.h"

@interface CDROTestReporter ()
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;

@property (strong, nonatomic) NSString *currentSuiteName;
@property (strong, nonatomic) CDRExampleGroup *currentSuite;

@property (strong, nonatomic) NSArray *rootGroups;
@property (assign, nonatomic) NSUInteger failedCount;
@end

@implementation CDROTestReporter

- (void)runWillStartWithGroups:(NSArray *)groups andRandomSeed:(unsigned int)seed
{
    self.startTime = [NSDate date];
    self.rootGroups = groups;
    [self startObservingExamples:self.rootGroups];

    [self startSuite:@"All tests" atDate:self.startTime];
    [self startSuite:[self bundleSuiteName] atDate:self.startTime];
}

- (void)runDidComplete
{
    if (self.currentSuiteName){
        [self finishSuite:self.currentSuiteName atDate:[NSDate date]];
        [self printStatsForExamples:@[self.currentSuite]];
    }
    self.endTime = [NSDate date];
    [self stopObservingExamples:self.rootGroups];

    [self finishSuite:[self bundleSuiteName] atDate:self.endTime];
    [self printStatsForExamples:self.rootGroups];
    [self finishSuite:@"All tests" atDate:self.endTime];
    [self printStatsForExamples:self.rootGroups];
}

- (int)result
{
    if ([SpecHelper specHelper].shouldOnlyRunFocused || self.failedCount) {
        return 1;
    } else {
        return 0;
    }
}


#pragma mark - Private

- (NSString *)bundleSuiteName
{
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    return testBundle.bundleURL.pathComponents.lastObject;
}

- (void)startSuite:(NSString *)name atDate:(NSDate *)date
{
    fprintf(stderr, "Test Suite '%s' started at %s\n", name.UTF8String, date.description.UTF8String);
}

- (void)finishSuite:(NSString *)name atDate:(NSDate *)date
{
    fprintf(stderr, "Test Suite '%s' finished at %s.\n", name.UTF8String, date.description.UTF8String);
}

- (void)reportOnExample:(CDRExample *)example
{
    NSString *testSuite = [NSString stringWithFormat:@"%@Spec", example.fullTextInPieces[0]];
    NSArray *fullTextPieces = example.fullTextInPieces;
    NSString *caseName = [[[fullTextPieces subarrayWithRange:NSMakeRange(1, fullTextPieces.count - 1)]
                           componentsJoinedByString:@"_"] stringByReplacingOccurrencesOfString:@" " withString:@"_"];

    NSString *status = nil;
    NSString *errorMessage = nil;

    switch (example.state) {
        case CDRExampleStatePassed:
            status = @"passed";
            break;
        case CDRExampleStatePending:
            status = @"pending";
            break;
        case CDRExampleStateSkipped:
            status = @"skipped";
            break;
        case CDRExampleStateFailed:
        case CDRExampleStateError:
            ++self.failedCount;
            status = @"failed";
            errorMessage = [self recordFailedExample:example
                                           suiteName:testSuite
                                            caseName:caseName];
            break;
        default:
            break;
    }

    if (![self.currentSuiteName isEqual:testSuite]) {

        if (self.currentSuiteName) {
            [self finishSuite:self.currentSuiteName atDate:[NSDate date]];
            [self printStatsForExamples:@[self.currentSuite]];
        }

        NSDate *startTime = [NSDate dateWithTimeIntervalSinceNow:-example.runTime];
        [self startSuite:testSuite atDate:startTime];
    }

    fprintf(stderr, "Test Case '-[%s %s]' started.\n", testSuite.UTF8String, caseName.UTF8String);

    if (errorMessage){
        fprintf(stderr, "%s\n", errorMessage.UTF8String);
    }
    fprintf(stderr, "Test Case '-[%s %s]' %s (%.3f seconds).\n",
            testSuite.UTF8String, caseName.UTF8String, status.UTF8String, example.runTime);

    self.currentSuiteName = testSuite;
    self.currentSuite = (CDRExampleGroup *)example.parent;
}

- (NSString *)recordFailedExample:(CDRExample *)example
                        suiteName:(NSString *)suiteName
                         caseName:(NSString *)caseName
{
    NSString *errorDescription = [example.failure.reason stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    NSString *errorMessage = [NSString stringWithFormat:@"%@:%d: error: -[%@ %@] : %@",
                              example.failure.fileName, example.failure.lineNumber,
                              suiteName, caseName,
                              errorDescription];
    return errorMessage;
}

- (void)printStatsForExamples:(NSArray *)examples {
    NSDictionary *stats = [self statsForExamples:examples];
    NSUInteger count = [stats[@"count"] unsignedIntegerValue];
    NSUInteger failed = [stats[@"failed"] unsignedIntegerValue];
    NSUInteger unexpected = [stats[@"unexpected"] unsignedIntegerValue];
    const char *testsString = count == 1 ? "test" : "tests";
    const char *failuresString = failed == 1 ? "failure" : "failures";
    float totalTimeElapsed = [self.endTime timeIntervalSinceDate:self.startTime];

    fprintf(stderr, "Executed %lu %s, with %lu %s (%lu unexpected) in %.4f (%.4f) seconds\n",
            (unsigned long)count, testsString,
            (unsigned long)failed, failuresString,
            (unsigned long)unexpected,
            totalTimeElapsed, totalTimeElapsed);
}

- (NSDictionary *)statsForExamples:(NSArray *)examples
{
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
            count += [stats[@"count"] unsignedIntegerValue];
            unexpected += [stats[@"unexpected"] unsignedIntegerValue];
            failed += [stats[@"failed"] unsignedIntegerValue];
        }
    }
    return @{@"count": @(count),
             @"unexpected": @(unexpected),
             @"failed": @(failed)};
}


- (void)startObservingExamples:(NSArray *)examples {
    for (id example in examples) {
        if (![example hasChildren]) {
            [example addObserver:self forKeyPath:@"state" options:0 context:NULL];
        } else {
            [self startObservingExamples:[example examples]];
        }
    }
}

- (void)stopObservingExamples:(NSArray *)examples {
    for (id example in examples) {
        if (![example hasChildren]) {
            [example removeObserver:self forKeyPath:@"state"];
        } else {
            [self stopObservingExamples:[example examples]];
        }
    }
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self reportOnExample:object];
}

@end
