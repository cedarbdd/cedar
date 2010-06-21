#import "CDRExample.h"
#import "CDRExampleRunner.h"

const CDRSpecBlock PENDING = nil;

@interface CDRExample (private)
- (void)setState:(CDRExampleState)state;
@end


@implementation CDRExample

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

- (CDRExampleState)state {
    return state_;
}

- (float)progress {
    if (self.state == CDRExampleStateIncomplete) {
        return 0.0;
    } else {
        return 1.0;
    }
}

- (void)runWithRunner:(id<CDRExampleRunner>)runner {
    if (block_) {
        @try {
            [parent_ setUp];
            block_();
            self.state = CDRExampleStatePassed;
            [runner exampleSucceeded:self];
        } @catch (CDRSpecFailure *x) {
            self.state = CDRExampleStateFailed;
            [runner example:self failedWithMessage:[x reason]];
        } @catch (NSException *x) {
            self.state = CDRExampleStateError;
            [runner example:self threwException:x];
        } @catch (...) {
            self.state = CDRExampleStateError;
            [runner exampleThrewError:self];
        }
        [parent_ tearDown];
    } else {
        self.state = CDRExampleStatePending;
        [runner examplePending:self];
    }
}

#pragma mark private interface

- (void)setState:(CDRExampleState)state {
    [self willChangeValueForKey:@"state"];
    state_ = state;
    [self didChangeValueForKey:@"state"];

    [parent_ stateDidChange];
}

@end
