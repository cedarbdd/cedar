#import <Cedar/CDRExampleBase.h>

@interface CDRExampleGroup : CDRExampleBase
{
    NSMutableArray *beforeBlocks_, *examples_, *afterBlocks_;
    NSUInteger _errorExamples;
    NSUInteger _failedExamples;
    NSUInteger _pendingExamples;
    NSUInteger _successfulExamples;
    NSUInteger _totalExamples;
    
    BOOL       _totalNeedsUpdate;
}

@property(nonatomic, readonly) NSArray *examples;

+ (id)groupWithText:(NSString *)text;

- (void)add:(CDRExampleBase *)example;
- (void)addBefore:(CDRSpecBlock)block;
- (void)addAfter:(CDRSpecBlock)block;

- (BOOL)isRoot;

- (void)setUp;
- (void)tearDown;

@end
