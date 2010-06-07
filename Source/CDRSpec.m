#import "CDRSpec.h"
#import "CDRExample.h"
#import "CDRExampleGroup.h"
#import "CDRExampleRunner.h"

static CDRSpec *currentSpec;

void describe(NSString *text, CDRSpecBlock block) {
  CDRExampleGroup *parentGroup = currentSpec.currentGroup;
  currentSpec.currentGroup = [CDRExampleGroup groupWithText:[NSString stringWithFormat:@"%@ %@", parentGroup.text, text]];
  [parentGroup add:currentSpec.currentGroup];

  block();
  currentSpec.currentGroup = parentGroup;
}

void beforeEach(CDRSpecBlock block) {
  [currentSpec.currentGroup addBefore:block];
}

void afterEach(CDRSpecBlock block) {
  [currentSpec.currentGroup addAfter:block];
}

void it(NSString *text, CDRSpecBlock block) {
  CDRExample *example = [CDRExample exampleWithText:[NSString stringWithFormat:@"%@ %@", currentSpec.currentGroup.text, text] andBlock:block];
  [currentSpec.currentGroup add:example];
}

void fail(NSString *reason) {
  [[CDRSpecFailure specFailureWithReason:[NSString stringWithFormat:@"Failure: %@", reason]] raise];
}

@implementation CDRSpec

@synthesize currentGroup = currentGroup_, rootGroup = rootGroup_;

#pragma mark Memory
- (id)init {
  if (self = [super init]) {
    rootGroup_ = [[CDRExampleGroup alloc] initWithText:@"Example:"];
    self.currentGroup = rootGroup_;
  }
  return self;
}

- (void)dealloc {
  self.rootGroup = nil;
  self.currentGroup = nil;

  [super dealloc];
}

- (void)declareBehaviors {
}

- (void)defineBehaviors {
  currentSpec = self;
  [self declareBehaviors];
  currentSpec = nil;
}

- (void)runWithRunner:(id<CDRExampleRunner>)runner {
  [self.rootGroup runWithRunner:runner];
}

- (void)failWithException:(NSException *)exception {
  [[CDRSpecFailure specFailureWithReason:[exception reason]] raise];
}

@end
