#import "CDRExampleBase.h"
#import "CDRNullabilityCompat.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDRExampleGroup : CDRExampleBase <CDRExampleParent> {
    NSMutableArray *beforeBlocks_, *examples_, *afterBlocks_;
    BOOL isRoot_;
    CDRSpecBlock subjectActionBlock_;
}

@property (nonatomic, copy, nullable) CDRSpecBlock subjectActionBlock;
@property (nonatomic, readonly) NSArray *examples;

+ (id)groupWithText:(NSString *)text;

- (id)initWithText:(NSString *)text isRoot:(BOOL)isRoot;
- (void)add:(CDRExampleBase *)example;
- (void)addBefore:(CDRSpecBlock)block;
- (void)addAfter:(CDRSpecBlock)block;

@end

NS_ASSUME_NONNULL_END
