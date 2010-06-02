#import "CDRExampleRunner.h"

@interface CDRDefaultRunner : NSObject <CDRExampleRunner> {
  NSMutableArray *pendingMessages_;
  NSMutableArray *failureMessages_;
}

@end