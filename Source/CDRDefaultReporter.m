#import "CDRDefaultReporter.h"
#import "CDRExample.h"
#import "CDRExampleGroup.h"
#import "SpecHelper.h"

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
    [failureMessages_ release];
    [skippedMessages_ release];
    [pendingMessages_ release];
    [super dealloc];
}

#pragma mark Public interface
- (void)runWillStartWithGroups:(NSArray *)groups {
    rootGroups_ = [groups retain];
    [self startObservingExamples:rootGroups_];
    startTime_ = [[NSDate alloc] init];
}

- (void)runDidComplete {
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
    return [NSString stringWithFormat:@"FAILURE %@\n%@\n", [example fullText], [example message]];
}

- (NSString *)errorToken {
    return @"E";
}

- (NSString *)errorMessageForExample:(CDRExample *)example {
    return [NSString stringWithFormat:@"EXCEPTION %@\n%@\n", [example fullText], [example message]];
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
            ++exampleCount_;
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

- (void)reportOnExample:(CDRExample *)example {
    switch (example.state) {
        case CDRExampleStatePassed:
            printf("%s", [[self successToken] cStringUsingEncoding:NSUTF8StringEncoding]);
            break;
        case CDRExampleStatePending:
            printf("%s", [[self pendingToken] cStringUsingEncoding:NSUTF8StringEncoding]);
            [pendingMessages_ addObject:[self pendingMessageForExample:example]];
            break;
        case CDRExampleStateSkipped:
            printf("%s", [[self skippedToken] cStringUsingEncoding:NSUTF8StringEncoding]);
            [skippedMessages_ addObject:[self skippedMessageForExample:example]];
            break;
        case CDRExampleStateFailed:
            printf("%s", [[self failureToken] cStringUsingEncoding:NSUTF8StringEncoding]);
            [failureMessages_ addObject:[self failureMessageForExample:example]];
            break;
        case CDRExampleStateError:
            printf("%s", [[self errorToken] cStringUsingEncoding:NSUTF8StringEncoding]);
            [failureMessages_ addObject:[self errorMessageForExample:example]];
            break;
        default:
            break;
    }
}

- (void)printStats {
    printf("\nFinished in %.4f seconds\n\n", [[NSDate date] timeIntervalSinceDate:startTime_]);
    printf("%u examples, %u failures", exampleCount_, (unsigned int)failureMessages_.count);

    if (pendingMessages_.count) {
        printf(", %u pending", (unsigned int)pendingMessages_.count);
    }

    if (skippedMessages_.count) {
        printf(", %u skipped", (unsigned int)skippedMessages_.count);
    }

    printf("\n");
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self reportOnExample:object];
}

@end
