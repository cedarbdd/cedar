#import "CDRExampleGroup.h"

@implementation CDRExampleGroup

#pragma mark Memory
+ (id)groupWithText:(NSString *)text {
  return [[[[self class] alloc] initWithText: text] autorelease];
}

- (id)initWithText:(NSString *)text {
  if (self = [super initWithText:text]) {
    beforeBlocks_ = [[NSMutableArray alloc] init];
    examples_ = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc {
  [examples_ release];
  [beforeBlocks_ release];
  [super dealloc];
}

#pragma mark Public interface
- (void)add:(CDRExampleBase *)example {
  example.parent = self;
  [examples_ addObject:example];
}

- (void)addBefore:(CDRSpecBlock)block {
  CDRSpecBlock blockCopy = [block copy];
  [beforeBlocks_ addObject:blockCopy];
  [blockCopy release];
}

- (void)setUp {
  [parent_ setUp];
  for (CDRSpecBlock beforeBlock in beforeBlocks_) {
    beforeBlock();
  }
}

- (void)runWithRunner:(id<CDRExampleRunner>)runner {
  for (CDRExampleBase *example in examples_) {
    [example runWithRunner:runner];
  }
}

- (NSString *)description {
  return [NSString stringWithFormat:@"Example Group: %@", self.text];
}

@end
