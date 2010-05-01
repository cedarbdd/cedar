#import "CDRExampleRunner.h"

@interface CDRDefaultRunner : NSObject <CDRExampleRunner> {
  NSMutableArray *failureMessages_;
}

@end