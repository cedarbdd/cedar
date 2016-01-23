#import <Foundation/Foundation.h>
#import "Cedar.h"
#import "CDRNullabilityCompat.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestReporter : NSObject <CDRExampleReporter>

@property (nonatomic, readonly) NSArray *startedExamples;
@property (nonatomic, readonly) NSArray *finishedExamples;

@property (nonatomic, readonly) NSArray *startedExampleGroups;
@property (nonatomic, readonly) NSArray *finishedExampleGroups;

@end

NS_ASSUME_NONNULL_END
