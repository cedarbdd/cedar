#import "CDRExampleReporter.h"

@class CDRExample;

@interface CDRDefaultReporter : NSObject <CDRExampleReporter> {
    NSString *cedarVersionString_;

    NSArray *rootGroups_;

    NSMutableArray *pendingMessages_;
    NSMutableArray *skippedMessages_;
    NSMutableArray *failureMessages_;

    NSDate *startTime_;
    NSDate *endTime_;
    unsigned int exampleCount_;
}

- (instancetype)initWithCedarVersion:(NSString *)cedarVersionString;

@end

@interface CDRDefaultReporter (Protected)
@property (nonatomic) unsigned int exampleCount;
- (NSString *)successToken;
- (NSString *)pendingToken;
- (NSString *)pendingMessageForExample:(CDRExample *)example;
- (NSString *)skippedToken;
- (NSString *)skippedMessageForExample:(CDRExample *)example;
- (NSString *)failureToken;
- (NSString *)failureMessageForExample:(CDRExample *)example;
- (NSString *)errorToken;
- (NSString *)errorMessageForExample:(CDRExample *)example;

- (void)reportOnExample:(CDRExample *)example;
- (void)printStats;
- (void)logText:(NSString *)linePartial;
@end
