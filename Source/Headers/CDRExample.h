#import "CDRExampleBase.h"

@interface CDRExample : CDRExampleBase {
  CDRSpecBlock block_;
}

+ (id)exampleWithText:(NSString *)text andBlock:(CDRSpecBlock)block;

- (id)initWithText:(NSString *)text andBlock:(CDRSpecBlock)block;

- (void)runWithRunner:(id<CDRExampleRunner>)runner;

@end
