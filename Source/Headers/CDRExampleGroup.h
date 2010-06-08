#import "CDRExampleBase.h"

@interface CDRExampleGroup : CDRExampleBase {
  NSMutableArray *beforeBlocks_, *examples_, *afterBlocks_;
}

@property (nonatomic, readonly) NSArray *examples;

+ (id)groupWithText:(NSString *)text;

- (void)add:(CDRExampleBase *)example;
- (void)addBefore:(CDRSpecBlock)block;
- (void)addAfter:(CDRSpecBlock)block;

@end
