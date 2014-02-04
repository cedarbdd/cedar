#import "CDRBufferedDefaultReporter.h"

@interface CDRBufferedDefaultReporter ()
@property (retain, nonatomic) NSMutableString *buffer;
@end

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

- (void)printStats {
    [super printStats];

    printf("%s", [self.buffer UTF8String]);
}

- (void)logText:(NSString *)linePartial {
    [self.buffer appendString:linePartial];
}

@end
