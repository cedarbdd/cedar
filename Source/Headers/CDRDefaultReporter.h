#import "CDRExampleReporter.h"

@interface CDRDefaultReporter : NSObject <CDRExampleReporter> {
    NSArray *rootGroups_;

    NSMutableArray *pendingMessages_;
    NSMutableArray *failureMessages_;

    NSDate *startTime_;
    unsigned int exampleCount_;
}

@end
