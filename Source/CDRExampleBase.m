#import "CDRExampleBase.h"

@implementation CDRSpecFailure

+ (id)specFailureWithReason:(NSString *)reason {
  return [[self class] exceptionWithName:@"Spec failure" reason:reason userInfo:nil];
}

@end

@implementation CDRExampleBase

@synthesize text = text_, parent = parent_;

- (id)initWithText:(NSString *)text {
  if (self = [super init]) {
    text_ = [text retain];
  }
  return self;
}

- (void)dealloc {
  [text_ release];
  [super dealloc];
}

- (void)setUp {
}

- (void)tearDown {
}

- (void)run {
}

- (BOOL)hasChildren {
    return NO;
}

- (NSString *)fullText {
    if (self.parent) {
        return [NSString stringWithFormat:@"%@ %@", [self.parent fullText], self.text];
    } else {
        return self.text;
    }
}

- (NSString *)message {
    return @"";
}

@end
