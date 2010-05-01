#import "CDRExampleBase.h"

@interface CDRExampleGroup : CDRExampleBase {
  NSMutableArray *beforeBlocks_;
  NSMutableArray *examples_;
}

+ (id)groupWithText:(NSString *)text;

- (id)initWithText:(NSString *)text;

- (void)add:(CDRExampleBase *)example;
- (void)addBefore:(CDRSpecBlock)block;
- (void)setUp;
- (void)runWithRunner:(id<CDRExampleRunner>)runner;

@end
