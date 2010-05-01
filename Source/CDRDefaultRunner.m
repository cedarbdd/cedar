#import "CDRDefaultRunner.h"
#import "CDRExample.h"

@implementation CDRDefaultRunner

#pragma mark Memory
- (id)init {
  if (self = [super init]) {
    failureMessages_ = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc {
  [failureMessages_ release];
  [super dealloc];
}

#pragma mark Public interface
- (void)exampleSucceeded:(CDRExample *)example {
  printf(".");
}
- (void)example:(CDRExample *)example failedWithMessage:(NSString *)message {
  printf("F");
  [failureMessages_ addObject:[NSString stringWithFormat:@"%@ FAILED:\n%@\n", [example text], message]];
}

- (void)example:(CDRExample *)example threwException:(NSException *)exception {
  printf("E");
  [failureMessages_ addObject:[NSString stringWithFormat:@"%@ THREW EXCEPTION:\n%@\n", [example text], exception]];
}

- (void)exampleThrewError:(CDRExample *)example {
  printf("E");
  [failureMessages_ addObject:[NSString stringWithFormat:@"%@ RAISED AN UNKNOWN ERROR\n", [example text]]];
}

- (int)result {
  if ([failureMessages_ count]) {
    printf("\n\n");

    for (NSString *message in failureMessages_) {
      printf("%s\n", [message cStringUsingEncoding:NSUTF8StringEncoding]);
    }

    return 1;
  } else {
    return 0;
  }
}

@end
