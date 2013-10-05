#import "CDRDefaultReporter.h"
#import "CDRExample.h"
#import "CDRExampleGroup.h"
#import "CDRSymbolicator.h"
#import "SpecHelper.h"
#import "CDRSlowTestStatistics.h"

@interface CDRDefaultReporter (private)
- (void)printMessages:(NSArray *)messages;
- (void)startObservingExamples:(NSArray *)examples;
- (void)stopObservingExamples:(NSArray *)examples;
- (void)reportOnExample:(CDRExample *)example;
- (void)printStats;
@end

@implementation CDRDefaultReporter

#pragma mark Memory
- (id)init {
    if (self = [super init]) {
        pendingMessages_ = [[NSMutableArray alloc] init];
        skippedMessages_ = [[NSMutableArray alloc] init];
        failureMessages_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [rootGroups_ release];
    [startTime_ release];
    [endTime_ release];
    [failureMessages_ release];
    [skippedMessages_ release];
    [pendingMessages_ release];
    [super dealloc];
}

#pragma mark Public interface
- (void)runWillStartWithGroups:(NSArray *)groups andRandomSeed:(unsigned int)seed {
    rootGroups_ = [groups retain];
    [self startObservingExamples:rootGroups_];
    startTime_ = [[NSDate alloc] init];
    printf("Running With Random Seed: %i\n\n", seed);
}

- (void)runDidComplete {
    endTime_ = [[NSDate alloc] init];
    [self stopObservingExamples:rootGroups_];

    printf("\n");
    if ([pendingMessages_ count]) {
        [self printMessages:pendingMessages_];
    }

    if ([failureMessages_ count]) {
        [self printMessages:failureMessages_];
    }

    [self printStats];
}

- (int)result {
    if ([SpecHelper specHelper].shouldOnlyRunFocused || [failureMessages_ count]) {
        return 1;
    } else {
        return 0;
    }
}

#pragma mark Protected interface
- (unsigned int)exampleCount {
    return exampleCount_;
}

- (NSString *)successToken {
    return @".";
}

- (NSString *)pendingToken {
    return @"P";
}

- (NSString *)pendingMessageForExample:(CDRExample *)example {
    return [NSString stringWithFormat:@"PENDING %@", [example fullText]];
}

- (NSString *)skippedToken {
    return @">";
}

- (NSString *)skippedMessageForExample:(CDRExample *)example {
    return [NSString stringWithFormat:@"SKIPPED %@", [example fullText]];
}

- (NSString *)failureToken {
    return @"F";
}

- (NSString *)failureMessageForExample:(CDRExample *)example {
    return [NSString stringWithFormat:@"FAILURE %@\n%@\n",
            example.fullText, example.failure];
}

- (NSString *)errorToken {
    return @"E";
}

- (NSString *)errorMessageForExample:(CDRExample *)example {
    return [NSString stringWithFormat:@"EXCEPTION %@\n%@\n%@",
            example.fullText, example.failure,
            [self callStackSymbolsForFailure:example.failure]];
}

- (NSString *)callStackSymbolsForFailure:(CDRSpecFailure *)failure {
    // Currently to symbolicate an exception
    // we shell out to atos; thus this opt-in setting.
    if (!getenv("CEDAR_SYMBOLICATE_EXCEPTIONS")) return nil;

    NSError *error = nil;
    NSString *callStackSymbols =
        [failure callStackSymbolicatedSymbols:&error];

    if (error.domain == kCDRSymbolicatorErrorDomain) {
        if (error.code == kCDRSymbolicatorErrorNotSuccessful) {
            NSString *details = [error.userInfo objectForKey:kCDRSymbolicatorErrorMessageKey];
            printf("Exception symbolication was not successful.\n"
                   "To turn it off remove CEDAR_SYMBOLICATE_EXCEPTIONS.\n"
                   "Details:\n%s\n", details.UTF8String);
        }
    }
    return callStackSymbols;
}

#pragma mark Private interface

- (void)printMessages:(NSArray *)messages {
    printf("\n");

    for (NSString *message in messages) {
        printf("%s\n", [message cStringUsingEncoding:NSUTF8StringEncoding]);
    }
}

- (void)startObservingExamples:(NSArray *)examples {
    for (id example in examples) {
        if (![example hasChildren]) {
            [example addObserver:self forKeyPath:@"state" options:0 context:NULL];
            if (![example isKindOfClass:[CDRExampleGroup class]]) {
                ++exampleCount_;
            }
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

- (void)printNestedFullTextForExample:(CDRExample *)example stateToken:(NSString *)token {
    static NSMutableArray *previousBranch = nil;
    NSUInteger previousBranchLength = previousBranch.count;

    NSMutableArray *exampleBranch = [example fullTextInPieces];
    NSUInteger exampleBranchLength = exampleBranch.count;

    BOOL onPreviousBranch = YES;

    for (int i=0; i<exampleBranchLength; i++) {
        onPreviousBranch &= (previousBranchLength > i && [[exampleBranch objectAtIndex:i] isEqualToString:[previousBranch objectAtIndex:i]]);

        if (!onPreviousBranch) {
            const char *indicator = (exampleBranchLength - i) == 1 ? [token UTF8String] : " ";
            printf("%s  %*s%s\n", indicator, 2*i, "", [[exampleBranch objectAtIndex:i] UTF8String]);
        }
    }

    [previousBranch release];
    previousBranch = exampleBranch;

    [[previousBranch retain] removeLastObject];
}

- (void)reportOnExample:(CDRExample *)example {
    NSString *stateToken = nil;

    switch (example.state) {
        case CDRExampleStatePassed:
            stateToken = [self successToken];
            break;
        case CDRExampleStatePending:
            stateToken = [self pendingToken];
            [pendingMessages_ addObject:[self pendingMessageForExample:example]];
            break;
        case CDRExampleStateSkipped:
            stateToken = [self skippedToken];
            [skippedMessages_ addObject:[self skippedMessageForExample:example]];
            break;
        case CDRExampleStateFailed:
            stateToken = [self failureToken];
            [failureMessages_ addObject:[self failureMessageForExample:example]];
            break;
        case CDRExampleStateError:
            stateToken = [self errorToken];
            [failureMessages_ addObject:[self errorMessageForExample:example]];
            break;
        default:
            break;
    }

    const char *reporterOpts = getenv("CEDAR_REPORTER_OPTS");

    if (reporterOpts && strcmp(reporterOpts, "nested") == 0) {
        [self printNestedFullTextForExample:example stateToken:stateToken];
    } else {
        printf("%s", [stateToken cStringUsingEncoding:NSUTF8StringEncoding]);
    }

    if (getenv("CEDAR_REPORT_FAILURES_IMMEDIATELY")) {
        if (example.state == CDRExampleStateFailed || example.state == CDRExampleStateError) {
            printf("\n%s", [[failureMessages_ lastObject] cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }
}

- (void)printStats {
    printf("\nFinished in %.4f seconds\n\n", [endTime_ timeIntervalSinceDate:startTime_]);
    printf("%u examples, %u failures", exampleCount_, (unsigned int)failureMessages_.count);

    if (pendingMessages_.count) {
        printf(", %u pending", (unsigned int)pendingMessages_.count);
    }

    if (skippedMessages_.count) {
        printf(", %u skipped", (unsigned int)skippedMessages_.count);
    }

    printf("\n");

    if (getenv("CEDAR_REPORT_SLOW_TESTS")) {
        CDRSlowTestStatistics *slowTestStats = [[[CDRSlowTestStatistics alloc] init] autorelease];
        [slowTestStats printStatsForExampleGroups:rootGroups_];
    }
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self reportOnExample:object];
}

@end
