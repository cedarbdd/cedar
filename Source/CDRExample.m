#import "CDRExample.h"
#import "CDRExampleReporter.h"

const CDRSpecBlock PENDING = nil;

@interface CDRExample ()
@property(nonatomic, readwrite) CDRExampleState state;
@end

@implementation CDRExample

@synthesize message = message_, state = state_;

+ (id)exampleWithText:(NSString *)text andBlock:(CDRSpecBlock)block
{
    return [[[[self class] alloc] initWithText:text andBlock:block] autorelease];
}

- (id)initWithText:(NSString *)text andBlock:(CDRSpecBlock)block
{
    if((self = [super initWithText:text]))
    {
        block_ = [block copy];
        state_ = (block_ != nil ? CDRExampleStateIncomplete : CDRExampleStatePending);
    }
    return self;
}

- (void)dealloc
{
    [block_   release];
    [message_ release];
    [super    dealloc];
}

#pragma mark CDRExampleBase

- (NSString *)message
{
    return (message_ ? : [super message]);
}

- (void)run
{
    if(block_ != nil)
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        @try
        {
            [parent_ setUp];
            block_();
            self.state = CDRExampleStatePassed;
        }
        @catch(CDRSpecFailure *x)
        {
            self.message = [x reason];
            self.state = CDRExampleStateFailed;
        }
        @catch(id x)
        {
            self.message = [x description];
            self.state = CDRExampleStateError;
        }
        @finally
        {
            [parent_ tearDown];
            [pool drain];
        }
    }
}

@end
