#import "CDRBufferedDefaultReporter.h"

@implementation CDRBufferedDefaultReporter

- (void)dealloc {
    self.buffer = nil;
    [super dealloc];
}

#pragma mark Overrides
- (void)runWillStartWithGroups:(NSArray *)groups andRandomSeed:(unsigned int)seed {
    self.buffer = [NSMutableString string];
    [super runWillStartWithGroups:groups andRandomSeed:seed];
}

- (void)runDidComplete {
    [super runDidComplete];

    printf("%s", [self.buffer UTF8String]);
}

- (void)logText:(NSString *)linePartial {
    [self.buffer appendString:linePartial];
}

@end
