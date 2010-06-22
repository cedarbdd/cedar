#import "CDRExampleGroup.h"

@implementation CDRExampleGroup

@synthesize examples = examples_;

#pragma mark Memory
+ (id)groupWithText:(NSString *)text {
  return [[[[self class] alloc] initWithText: text] autorelease];
}

- (id)initWithText:(NSString *)text {
  if (self = [super initWithText:text]) {
    beforeBlocks_ = [[NSMutableArray alloc] init];
    examples_ = [[NSMutableArray alloc] init];
    afterBlocks_ = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc {
  [afterBlocks_ release];
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

- (void)addAfter:(CDRSpecBlock)block {
  CDRSpecBlock blockCopy = [block copy];
  [afterBlocks_ addObject:blockCopy];
  [blockCopy release];
}

- (void)setUp {
  [parent_ setUp];
  for (CDRSpecBlock beforeBlock in beforeBlocks_) {
    beforeBlock();
  }
}

- (void)tearDown {
  for (CDRSpecBlock afterBlock in afterBlocks_) {
    afterBlock();
  }
  [parent_ tearDown];
}

- (CDRExampleState)state {
    if (0 == [examples_ count]) {
        return CDRExampleStatePending;
    }

    CDRExampleState aggregateState = CDRExampleStateIncomplete;
    for (CDRExampleBase *example in examples_) {
        aggregateState |= [example state];
    }
    return aggregateState;
}

- (float)progress {
    if (0 == [examples_ count]) {
        return 1.0;
    }

    float aggregateProgress = 0.0;
    for (CDRExampleBase *example in examples_) {
        aggregateProgress += [example progress];
    }
    return aggregateProgress / [examples_ count];
}

- (void)stateDidChange {
    [self willChangeValueForKey:@"state"];
    [self didChangeValueForKey:@"state"];
    [parent_ stateDidChange];
}

- (void)run {
    [examples_ makeObjectsPerformSelector:@selector(run)];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"Example Group: %@", self.text];
}

- (BOOL)hasChildren {
    return [examples_ count] > 0;
}

@end
