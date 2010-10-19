#import "CDRExample.h"
#import "CDRExampleReporter.h"

const CDRSpecBlock PENDING = nil;

@interface CDRExample (Private)
- (void)setState:(CDRExampleState)state;
@end

@implementation CDRExample

@synthesize message = message_;

+ (id)exampleWithText:(NSString *)text andBlock:(CDRSpecBlock)block {
    return [[[[self class] alloc] initWithText:text andBlock:block] autorelease];
}

- (id)initWithText:(NSString *)text andBlock:(CDRSpecBlock)block {
    if (self = [super initWithText:text]) {
        block_ = [block copy];
        state_ = CDRExampleStateIncomplete;
    }
    return self;
}

- (void)dealloc {
    [block_ release];
    [super dealloc];
}

#pragma mark CDRExampleBase
- (CDRExampleState)state {
    return state_;
}

- (NSString *)message {
    if (message_) {
        return message_;
    } else {
        return [super message];
    }
}

- (float)progress {
    if (self.state == CDRExampleStateIncomplete) {
        return 0.0;
    } else {
        return 1.0;
    }
}

- (void)run {
    if (block_) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        @try {
            [parent_ setUp];
            block_();
            self.state = CDRExampleStatePassed;
        } @catch (CDRSpecFailure *x) {
            self.message = [x reason];
            self.state = CDRExampleStateFailed;
        } @catch (NSObject *x) {
            self.message = [x description];
            self.state = CDRExampleStateError;
        }
        [parent_ tearDown];
        [pool drain];
    } else {
        self.state = CDRExampleStatePending;
    }
}

#pragma mark Private interface

- (void)setState:(CDRExampleState)state {
    state_ = state;
}

@end
