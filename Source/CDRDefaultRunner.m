#import "CDRDefaultRunner.h"
#import "CDRExample.h"

@interface CDRDefaultRunner (private)
- (void)printMessages:(NSArray *)messages;
@end

@implementation CDRDefaultRunner

#pragma mark Memory
- (id)init {
  if (self = [super init]) {
    pendingMessages_ = [[NSMutableArray alloc] init];
    failureMessages_ = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc {
  [failureMessages_ release];
  [pendingMessages_ release];
  [super dealloc];
}

#pragma mark Public interface
- (void)exampleSucceeded:(CDRExample *)example {
  printf(".");
}
- (void)example:(CDRExample *)example failedWithMessage:(NSString *)message {
  printf("F");
  [failureMessages_ addObject:[NSString stringWithFormat:@"%@ FAILED:\n%@\n", [example fullText], message]];
}

- (void)example:(CDRExample *)example threwException:(NSException *)exception {
  printf("E");
  [failureMessages_ addObject:[NSString stringWithFormat:@"%@ THREW EXCEPTION:\n%@\n", [example fullText], exception]];
}

- (void)exampleThrewError:(CDRExample *)example {
  printf("E");
  [failureMessages_ addObject:[NSString stringWithFormat:@"%@ RAISED AN UNKNOWN ERROR\n", [example fullText]]];
}

- (void)examplePending:(CDRExample *)example {
  printf("P");
  [pendingMessages_ addObject:[NSString stringWithFormat:@"PENDING %@", [example fullText]]];
}

- (int)result {
  if ([pendingMessages_ count]) {
    [self printMessages:pendingMessages_];
  }

  if ([failureMessages_ count]) {
    [self printMessages:failureMessages_];

    return 1;
  } else {
    return 0;
  }
}

#pragma mark private interface

- (void)printMessages:(NSArray *)messages {
  printf("\n\n");

  for (NSString *message in messages) {
    printf("%s\n", [message cStringUsingEncoding:NSUTF8StringEncoding]);
  }
}

@end
