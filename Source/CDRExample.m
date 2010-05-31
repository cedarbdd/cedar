#import "CDRExample.h"
#import "CDRExampleRunner.h"

@implementation CDRExample

+ (id)exampleWithText:(NSString *)text andBlock:(CDRSpecBlock)block {
  return [[[[self class] alloc] initWithText:text andBlock:block] autorelease];
}

- (id)initWithText:(NSString *)text andBlock:(CDRSpecBlock)block {
  if (self = [super initWithText:text]) {
    block_ = [block copy];
  }
  return self;
}

- (void)dealloc {
  [block_ release];
  [super dealloc];
}

- (void)runWithRunner:(id<CDRExampleRunner>)runner {
  @try {
    [parent_ setUp];
    block_();
    [runner exampleSucceeded:self];
  } @catch (CDRSpecFailure *x) {
    [runner example:self failedWithMessage:[x reason]];
  } @catch (NSException *x) {
    [runner example:self threwException:x];
  } @catch (...) {
    [runner exampleThrewError:self];
  }
  [parent_ tearDown];
}

@end
