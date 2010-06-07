#import "CDRExample.h"
#import "CDRExampleRunner.h"

const CDRSpecBlock PENDING = nil;

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

- (void)runWithRunner:(id<CDRExampleRunner>)runner {
    if (block_) {
        @try {
            [parent_ setUp];
            block_();
            state_ = CDRExampleStatePassed;
            [runner exampleSucceeded:self];
        } @catch (CDRSpecFailure *x) {
            state_ = CDRExampleStateFailed;
            [runner example:self failedWithMessage:[x reason]];
        } @catch (NSException *x) {
            state_ = CDRExampleStateError;
            [runner example:self threwException:x];
        } @catch (...) {
            state_ = CDRExampleStateError;
            [runner exampleThrewError:self];
        }
        [parent_ tearDown];
    } else {
        state_ = CDRExampleStatePending;
        [runner examplePending:self];
    }
}

@end
