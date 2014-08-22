#import "CDRExample.h"
#import "CDRSpecHelper.h"
#import "CDRReportDispatcher.h"

const CDRSpecBlock PENDING = nil;

@interface CDRExample (Private)
- (void)setState:(CDRExampleState)state;
@end

@implementation CDRExample

@synthesize failure = failure_;

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
    self.failure = nil;
    [block_ release];
    [super dealloc];
}

#pragma mark CDRExampleBase
- (CDRExampleState)state {
    return state_;
}

- (NSString *)message {
    if (self.failure.reason) {
        return self.failure.reason;
    }
    return [super message];
}

- (float)progress {
    if (self.state == CDRExampleStateIncomplete) {
        return 0.0;
    } else {
        return 1.0;
    }
}

- (BOOL)isPending {
    return (self.state == CDRExampleStateIncomplete && block_ == nil) || self.state == CDRExampleStatePending;
}

- (void)runWithDispatcher:(CDRReportDispatcher *)dispatcher {
    if (self.state != CDRExampleStateIncomplete) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"Attempt to run example twice: %@", [self fullText]]
                               userInfo:nil] raise];
    }

    [startDate_ release];
    startDate_ = [[NSDate alloc] init];
    [dispatcher runWillStartExample:self];

    if (!self.shouldRun) {
        self.state = CDRExampleStateSkipped;
    } else if (self.isPending) {
        self.state = CDRExampleStatePending;
    } else {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        @try {
            [parent_ setUp];
            if (parent_.subjectActionBlock) { parent_.subjectActionBlock(); }
            block_();
            self.state = CDRExampleStatePassed;
        } @catch (CDRSpecFailure *x) {
            self.failure = x;
            self.state = CDRExampleStateFailed;
        } @catch (NSObject *x) {
            self.failure = [CDRSpecFailure specFailureWithRaisedObject:x];
            self.state = CDRExampleStateError;
        } @finally {
            @try {
                [parent_ tearDown];
            } @catch (NSObject *x) {
                if (self.state != CDRExampleStateFailed) {
                    self.failure = [CDRSpecFailure specFailureWithRaisedObject:x];
                    self.state = CDRExampleStateError;
                }
            }
        }
        [pool drain];
    }
    [endDate_ release];
    endDate_ = [[NSDate alloc] init];

    [dispatcher runDidFinishExample:self];

    [block_ release];
    block_ = nil;
}

#pragma mark Private interface
- (void)setState:(CDRExampleState)state {
    state_ = state;
}

@end

