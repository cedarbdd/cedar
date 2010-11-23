#import "CDRDefaultReporter.h"
#import "CDRExample.h"
#import "CDRExampleGroup.h"

static const char* ANSI_NORMAL = "\033[0m";
static const char* ANSI_GREEN = "\033[0;40;32m";
static const char* ANSI_RED = "\033[0;40;31m";
static const char* ANSI_YELLOW = "\033[0;40;33m";

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

        colorOutput_ = NO;
        char * ansiColorEnvSetting = getenv("CEDAR_ANSI_COLOR");
        if (ansiColorEnvSetting != NULL && strcmp(ansiColorEnvSetting, "0") != 0) {
            colorOutput_ = YES;
        }
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

    printf("\n");
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
    printf("\n");

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
    NSString *message;
    switch (example.state) {
        case CDRExampleStatePassed:
            if (colorOutput_) { printf("%s", ANSI_GREEN); }
            printf(".");
            break;
        case CDRExampleStatePending:
            message = [NSString stringWithFormat:@"PENDING %@", [example fullText]];
            if (colorOutput_) {
                printf("%s", ANSI_YELLOW);
                message = [NSString stringWithFormat:@"%s%@%s", ANSI_YELLOW, message, ANSI_NORMAL];
            }
            printf("P");
            [pendingMessages_ addObject:message];
            break;
        case CDRExampleStateFailed:
            message = [NSString stringWithFormat:@"FAILURE %@\n%@\n", [example fullText], [example message]];
            if (colorOutput_) {
                printf("%s", ANSI_RED);
                message = [NSString stringWithFormat:@"%s%@%s", ANSI_RED, message, ANSI_NORMAL];
            }
            printf("F");
            [failureMessages_ addObject:message];
            break;
        case CDRExampleStateError:
            message = [NSString stringWithFormat:@"EXCEPTION %@\n%@\n", [example fullText], [example message]];
            if (colorOutput_) {
                printf("%s", ANSI_RED);
                message = [NSString stringWithFormat:@"%s%@%s", ANSI_RED, message, ANSI_NORMAL];
            }
            printf("E");
            [failureMessages_ addObject:message];
            break;
        default:
            break;
    }
    if (colorOutput_) {
      printf("%s", ANSI_NORMAL);
    }
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self reportOnExample:object];
}


@end
