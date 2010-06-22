#import "SpecStatusCell.h"
#import "CDRExampleBase.h"

@implementation SpecStatusCell

@synthesize example = example_;

- (void)dealloc {
    self.example = nil;
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {
    UIColor *backgroundColor = [UIColor whiteColor];
    switch ([self.example state]) {
        case CDRExampleStatePassed:
            backgroundColor = [UIColor greenColor];
            break;
        case CDRExampleStatePending:
            backgroundColor = [UIColor yellowColor];
            break;
        case CDRExampleStateFailed:
        case CDRExampleStateError:
            backgroundColor = [UIColor redColor];
            break;
    }
    [self setBackgroundColor:backgroundColor];
    [super drawRect:rect];
}

- (void)setExample:(CDRExampleBase *)example {
    if (example_ != example) {
        [example_ release];
        example_ = [example retain];

        self.textLabel.text = example.text;
        [example_ addObserver:self forKeyPath:@"state" options:0 context:NULL];
    }
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:NULL waitUntilDone:NO];
}

@end
