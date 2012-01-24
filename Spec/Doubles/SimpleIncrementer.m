#import "SimpleIncrementer.h"

@implementation SimpleIncrementer

@synthesize value = value_;

- (void)increment {
    ++self.value;
}

- (void)incrementBy:(size_t)amount {
    self.value += amount;
}


@end
