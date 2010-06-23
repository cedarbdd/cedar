#import "CDRSpecStatusCell.h"
#import "CDRExampleBase.h"
#import "CDRExampleStateMap.h"

@interface CDRSpecStatusCell (Private)
- (void)setUpDisplayForExample:(CDRExampleBase *)example;
@end

@implementation CDRSpecStatusCell

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
    [self.contentView setBackgroundColor:backgroundColor];
    [self setBackgroundColor:backgroundColor];

    [super drawRect:rect];
}

- (void)setExample:(CDRExampleBase *)example {
    if (example_ != example) {
        [example_ release];
        example_ = [example retain];

        [self setUpDisplayForExample:example];
        [example_ addObserver:self forKeyPath:@"state" options:0 context:NULL];
    }
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self performSelectorOnMainThread:@selector(redrawCell) withObject:NULL waitUntilDone:NO];
}

#pragma mark Private interface
- (void)setUpDisplayForExample:(CDRExampleBase *)example {
    self.textLabel.text = example.text;
    self.detailTextLabel.text = [[CDRExampleStateMap stateMap] descriptionForState:self.example.state];
    if ([example_ hasChildren]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

- (void)redrawCell {
    self.detailTextLabel.text = [[CDRExampleStateMap stateMap] descriptionForState:self.example.state];
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

@end
