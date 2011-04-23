#import "CDRExampleBase.h"

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

- (NSString *)message {
    return @"";
}

- (NSString *)fullText {
    if (self.parent && [self.parent hasFullText]) {
        return [NSString stringWithFormat:@"%@ %@", [self.parent fullText], self.text];
    } else {
        return self.text;
    }
}

@end
