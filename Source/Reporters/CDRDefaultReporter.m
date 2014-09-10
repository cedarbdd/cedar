#import "CDRDefaultReporter.h"
#import "CDRExample.h"
#import "CDRExampleGroup.h"
#import "CDRSymbolicator.h"
#import "CDRSpecHelper.h"
#import "CDRSlowTestStatistics.h"

@interface CDRDefaultReporter (private)
- (void)printMessages:(NSArray *)messages;
- (void)reportOnExample:(CDRExample *)example;
- (void)printStats;
@end

@implementation CDRDefaultReporter

#pragma mark Memory
- (instancetype)initWithCedarVersion:(NSString *)cedarVersionString {
    if (self = [super init]) {
        cedarVersionString_ = [cedarVersionString retain];
        pendingMessages_ = [[NSMutableArray alloc] init];
        skippedMessages_ = [[NSMutableArray alloc] init];
        failureMessages_ = [[NSMutableArray alloc] init];
        exampleCount_ = 0;
    }
    return self;
}

- (void)dealloc {
    [cedarVersionString_ release];
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
    startTime_ = [[NSDate alloc] init];
    [self logText:[NSString stringWithFormat:@"Cedar Version: %@\n", cedarVersionString_]];
    [self logText:[NSString stringWithFormat:@"Running With Random Seed: %i\n\n", seed]];
}

- (void)runDidComplete {
    endTime_ = [[NSDate alloc] init];

    [self logText:@"\n"];
    if ([pendingMessages_ count]) {
        [self printMessages:pendingMessages_];
    }

    if ([failureMessages_ count]) {
        [self printMessages:failureMessages_];
    }

    [self printStats];
}

- (int)result {
    if ([CDRSpecHelper specHelper].shouldOnlyRunFocused || [failureMessages_ count]) {
        return 1;
    } else {
        return 0;
    }
}

- (void)runWillStartExample:(CDRExample *)example {
    exampleCount_++;
}

- (void)runDidFinishExample:(CDRExample *)example {
    [self reportOnExample:example];
}

- (void)runWillStartExampleGroup:(CDRExampleGroup *)exampleGroup {

}

- (void)runDidFinishExampleGroup:(CDRExampleGroup *)exampleGroup {

}

- (void)runWillStartSpec:(CDRSpec *)spec {

}

- (void)runDidFinishSpec:(CDRSpec *)spec {

}


#pragma mark Protected interface
- (void)logText:(NSString *)linePartial {
    printf("%s", [linePartial UTF8String]);
}

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
            [self logText:[NSString stringWithFormat:
                           @"Exception symbolication was not successful.\n"
                           @"To turn it off remove CEDAR_SYMBOLICATE_EXCEPTIONS.\n"
                           @"Details:\n%@\n", details]];
        }
    }
    return callStackSymbols;
}

#pragma mark Private interface

- (void)printMessages:(NSArray *)messages {
    [self logText:@"\n"];

    for (NSString *message in messages) {
        [self logText:[NSString stringWithFormat:@"%@\n", message]];
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
            NSString *indicator = (exampleBranchLength - i) == 1 ? token : @" ";
            [self logText:[NSString stringWithFormat:@"%@  %*s%@\n",
                           indicator, 2*i, "", [exampleBranch objectAtIndex:i]]];
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
        [self logText:stateToken];
    }

    if (getenv("CEDAR_REPORT_FAILURES_IMMEDIATELY")) {
        if (example.state == CDRExampleStateFailed || example.state == CDRExampleStateError) {
            [self logText:[NSString stringWithFormat:@"\n%@", [failureMessages_ lastObject]]];
        }
    }
}

- (void)printStats {
    [self logText:[NSString stringWithFormat:@"\nFinished in %.4f seconds\n\n", [endTime_ timeIntervalSinceDate:startTime_]]];
    [self logText:[NSString stringWithFormat:@"%u examples, %u failures", exampleCount_, (unsigned int)failureMessages_.count]];

    if (pendingMessages_.count) {
        [self logText:[NSString stringWithFormat:@", %u pending", (unsigned int)pendingMessages_.count]];
    }

    if (skippedMessages_.count) {
        [self logText:[NSString stringWithFormat:@", %u skipped", (unsigned int)skippedMessages_.count]];
    }

    [self logText:@"\n"];

    if (getenv("CEDAR_REPORT_SLOW_TESTS")) {
        CDRSlowTestStatistics *slowTestStats = [[[CDRSlowTestStatistics alloc] init] autorelease];
        [slowTestStats printStatsForExampleGroups:rootGroups_];
    }
}


@end
