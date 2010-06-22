#import "CDRExampleReporter.h"

@interface CDRDefaultReporter : NSObject <CDRExampleReporter> {
    NSArray *rootGroups_;

    NSMutableArray *pendingMessages_;
    NSMutableArray *failureMessages_;
}

@end
