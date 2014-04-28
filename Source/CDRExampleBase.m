#import "CDRExampleBase.h"
#import "CDRSpecHelper.h"
#import "CDRReportDispatcher.h"

@implementation CDRExampleBase

@synthesize text = text_, parent = parent_, focused = focused_, stackAddress = stackAddress_, startDate = startDate_,
    endDate = endDate_, spec = spec_;

- (id)initWithText:(NSString *)text {
    if (self = [super init]) {
        text_ = [text retain];
        focused_ = NO;
    }
    return self;
}

- (void)dealloc {
    [text_ release];
    [startDate_ release];
    [endDate_ release];
    self.spec = nil;
    self.parent = nil;
    [super dealloc];
}

- (void)setUp {
}

- (void)tearDown {
}

- (void)runWithDispatcher:(CDRReportDispatcher *)dispatcher {
}

- (BOOL)shouldRun {
    BOOL shouldOnlyRunFocused = [CDRSpecHelper specHelper].shouldOnlyRunFocused;
    return !shouldOnlyRunFocused || (shouldOnlyRunFocused && (self.isFocused || parent_.shouldRun));
}

- (BOOL)hasFocusedExamples {
    return self.isFocused;
}

- (BOOL)hasChildren {
    return NO;
}

- (CDRExampleState)state {
    return CDRExampleStateIncomplete;
}

- (NSString *)message {
    return @"";
}

- (NSString *)fullText {
    return [[self fullTextInPieces] componentsJoinedByString:@" "];
}

- (NSMutableArray *)fullTextInPieces {
    if (self.parent && [self.parent respondsToSelector:@selector(hasFullText)] && [self.parent hasFullText]) {
        NSMutableArray *array = [self.parent fullTextInPieces];
        [array addObject:self.text];
        return array;
    } else {
        return [NSMutableArray arrayWithObject:self.text];
    }
}

- (NSTimeInterval)runTime {
    return [endDate_ timeIntervalSinceDate:startDate_];
}

@end
