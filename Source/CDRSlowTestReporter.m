#import "CDRSlowTestReporter.h"
#import "CDRExampleGroup.h"
#import "CDRExample.h"

@interface RunTimeTitlePair : NSObject

@property (nonatomic, assign) NSTimeInterval runTime;
@property (nonatomic, retain) NSString *title;

+ (RunTimeTitlePair *)pairWithRunTime:(NSTimeInterval)runTime title:(NSString *)title;
- (NSString *)formattedDescription;

@end

@implementation RunTimeTitlePair

@synthesize runTime, title;

+ (RunTimeTitlePair *)pairWithRunTime:(NSTimeInterval)runTime title:(NSString *)title {
    RunTimeTitlePair *pair = [[[RunTimeTitlePair alloc] init] autorelease];
    pair.runTime = runTime;
    pair.title = title;
    return pair;
}

- (NSString *)formattedDescription {
    NSString *timeString = [NSString stringWithFormat:@"%7.3fs | ", self.runTime];
    NSString *newLinePrefix = [NSString stringWithFormat:@"\n         | "];

    NSArray *titleChunks = [self.title componentsSeparatedByString:@" "];
    NSMutableArray *lines = [NSMutableArray array];
    NSMutableArray *currentLine = [NSMutableArray array];
    int currentLineLength = 0;
    
    for (NSString *titleChunk in titleChunks) {
        if (currentLineLength > 0 && (titleChunk.length + 1 + currentLineLength > 70)) {
            [lines addObject:[currentLine componentsJoinedByString:@" "]];
            currentLine = [NSMutableArray array];
            currentLineLength = 0;
        }
        
        [currentLine addObject:titleChunk];
        currentLineLength += titleChunk.length + 1;
    }
    
    [lines addObject:[currentLine componentsJoinedByString:@" "]];

    NSString *description = [timeString stringByAppendingString:[lines componentsJoinedByString:newLinePrefix]];
    
    return description;
}

- (NSComparisonResult)compare:(RunTimeTitlePair *)otherPair {
    if (self.runTime > otherPair.runTime) {
        return NSOrderedDescending;
    } else if (self.runTime < otherPair.runTime) {
        return NSOrderedAscending;
    }
    
    return NSOrderedSame;
}

@end

@interface CDRSlowTestReporter ()

- (int)numberOfResultsToShow;
- (NSArray *)runTimeTitlePairsForGroup:(CDRExampleGroup *)group;

@end

@implementation CDRSlowTestReporter

- (int)numberOfResultsToShow {
    int numberOfResultsToShow = 10;
    if (getenv("CEDAR_TOP_N_SLOW_TESTS")) {
        numberOfResultsToShow = [[NSString stringWithUTF8String:getenv("CEDAR_TOP_N_SLOW_TESTS")] intValue];
    }
    return numberOfResultsToShow;
}

- (void)printStats {
    [super printStats];
    
    NSMutableArray *rootPairs = [NSMutableArray array];
    NSMutableArray *examplePairs = [NSMutableArray array];
    
    for (CDRExampleGroup *group in rootGroups_) {
        RunTimeTitlePair *pair = [RunTimeTitlePair pairWithRunTime:group.runTime
                                                             title:group.text];
        [rootPairs addObject:pair];
        [examplePairs addObjectsFromArray:[self runTimeTitlePairsForGroup:group]];
    }
    
    int numberOfResultsToShow = self.numberOfResultsToShow;
    
    NSArray *sortedRootPairs = [[[rootPairs sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator] allObjects];
    sortedRootPairs = [sortedRootPairs subarrayWithRange:NSMakeRange(0, MIN(numberOfResultsToShow, sortedRootPairs.count))];
    
    NSArray *sortedExamplePairs = [[[examplePairs sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator] allObjects];    
    sortedExamplePairs = [sortedExamplePairs subarrayWithRange:NSMakeRange(0, MIN(numberOfResultsToShow, sortedExamplePairs.count))];
    
    printf("\n%lu Slowest Tests\n\n", sortedExamplePairs.count);
    for (RunTimeTitlePair *pair in sortedExamplePairs) {
        printf("%s\n\n", pair.formattedDescription.UTF8String);
    }
    
    printf("\n%lu Slowest Top-Level Groups\n\n", sortedRootPairs.count);
    for (RunTimeTitlePair *pair in sortedRootPairs) {
        printf("%s\n\n", pair.formattedDescription.UTF8String);
    }
}

- (NSArray *)runTimeTitlePairsForGroup:(CDRExampleGroup *)group {
    NSMutableArray *pairs = [NSMutableArray array];

    if (group.hasChildren) {
        for (CDRExampleBase *example in group.examples) {
            if (example.hasChildren) {
                [pairs addObjectsFromArray:[self runTimeTitlePairsForGroup:(CDRExampleGroup *) example]];
            } else {
                RunTimeTitlePair *pair = [RunTimeTitlePair pairWithRunTime:example.runTime
                                                                     title:example.fullText];
                [pairs addObject:pair];
            }
        }
    }
    
    return pairs;
}

@end

