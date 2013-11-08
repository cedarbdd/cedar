#import "ArgumentReleaser.h"

@implementation ArgumentReleaser

- (void)releaseArgument:(id)arg {
    [arg release];
}

@end
