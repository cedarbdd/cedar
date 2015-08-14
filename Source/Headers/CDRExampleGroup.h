#import "CDRExampleBase.h"

@interface CDRExampleGroup : CDRExampleBase <CDRExampleParent> {
    NSMutableArray *beforeBlocks_, *examples_, *afterBlocks_, *invariants_;
    BOOL isRoot_;
    CDRSpecBlock subjectActionBlock_;
}

@property (nonatomic, copy) CDRSpecBlock subjectActionBlock;
@property (nonatomic, readonly) NSArray *examples;

+ (id)groupWithText:(NSString *)text;

- (id)initWithText:(NSString *)text isRoot:(BOOL)isRoot;
- (void)add:(CDRExampleBase *)example;
- (void)addBefore:(CDRSpecBlock)block;
- (void)addAfter:(CDRSpecBlock)block;
- (void)addInvariant:(CDRExampleBase *)inv;

@end
