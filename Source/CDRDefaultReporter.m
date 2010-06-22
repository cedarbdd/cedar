#import "CDRDefaultReporter.h"
#import "CDRExample.h"
#import "CDRExampleGroup.h"

@interface CDRDefaultReporter (private)
- (void)printMessages:(NSArray *)messages;
- (void)startObservingExamples:(NSArray *)examples;
- (void)stopObservingExamples:(NSArray *)examples;
- (void)reportOnExample:(CDRExample *)example;
@end

@implementation CDRDefaultReporter

#pragma mark Memory
- (id)init {
    if (self = [super init]) {
        pendingMessages_ = [[NSMutableArray alloc] init];
        failureMessages_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [rootGroups_ release];
    [failureMessages_ release];
    [pendingMessages_ release];
    [super dealloc];
}

#pragma mark Public interface
- (void)runWillStartWithGroups:(NSArray *)groups {
    rootGroups_ = [groups retain];
    [self startObservingExamples:rootGroups_];
}

- (void)runDidComplete {
    [self stopObservingExamples:rootGroups_];

    if ([pendingMessages_ count]) {
        [self printMessages:pendingMessages_];
    }

    if ([failureMessages_ count]) {
        [self printMessages:failureMessages_];
    }
}

- (int)result {
    if ([failureMessages_ count]) {
        return 1;
    } else {
        return 0;
    }
}

#pragma mark private interface

- (void)printMessages:(NSArray *)messages {
    printf("\n\n");

    for (NSString *message in messages) {
        printf("%s\n", [message cStringUsingEncoding:NSUTF8StringEncoding]);
    }
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

- (void)reportOnExample:(CDRExample *)example {
    switch (example.state) {
        case CDRExampleStatePassed:
            printf(".");
            break;
        case CDRExampleStatePending:
            printf("P");
            [pendingMessages_ addObject:[NSString stringWithFormat:@"PENDING %@", [example fullText]]];
            break;
        case CDRExampleStateFailed:
            printf("F");
            [failureMessages_ addObject:[NSString stringWithFormat:@"%@ FAILED:\n%@\n", [example fullText], [example message]]];
            break;
        case CDRExampleStateError:
            printf("E");
            [failureMessages_ addObject:[NSString stringWithFormat:@"%@ THREW EXCEPTION:\n%@\n", [example fullText], [example message]]];
            break;
        default:
            break;
    }
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self reportOnExample:object];
}


@end
