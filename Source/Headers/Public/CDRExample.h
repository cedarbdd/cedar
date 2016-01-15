#import "CDRExampleBase.h"
#import "CDRNullabilityCompat.h"
#import "CDRSpecFailure.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDRExample : CDRExampleBase {
    CDRSpecBlock block_;
    CDRExampleState state_;
    CDRSpecFailure *failure_;
}

@property (nonatomic, retain, nullable) CDRSpecFailure *failure;

+ (id)exampleWithText:(NSString *)text andBlock:(nullable CDRSpecBlock)block;
- (id)initWithText:(NSString *)text andBlock:(nullable CDRSpecBlock)block;
- (BOOL)isPending;

@end

NS_ASSUME_NONNULL_END
