#import "CDRExampleBase.h"
#import "CDRExampleGroup.h"

@implementation CDRSpecFailure

+ (id)specFailureWithReason:(NSString *)reason {
  return [[self class] exceptionWithName:@"Spec failure" reason:reason userInfo:nil];
}

@end

@implementation CDRExampleBase

@synthesize text = text_, parent = parent_;

- (id)initWithText:(NSString *)text
{
    if((self = [super init]))
    {
        text_ = [text copy];
    }
    return self;
}

- (void)dealloc
{
    [text_ release];
    [super dealloc];
}

- (void)run {
}

- (BOOL)hasChildren {
    return NO;
}

- (NSString *)message {
    return @"";
}

- (NSString *)fullText
{
    NSString *ret = [self text];
    
    if([self parent] != nil && ![[self parent] isRoot]) ret = [NSString stringWithFormat:@"%@ %@", [[self parent] fullText], ret];
    
    return ret;
}

@end

@implementation CDRExampleBase (RunReporting)

+ (NSSet *)keyPathsForValuesAffectingNumberOfErrors;
{
    return [NSSet setWithObject:@"state"];
}

+ (NSSet *)keyPathsForValuesAffectingNumberOfFailures;
{
    return [NSSet setWithObject:@"state"];
}

+ (NSSet *)keyPathsForValuesAffectingNumberOfPendingExamples;
{
    return [NSSet setWithObject:@"state"];
}

+ (NSSet *)keyPathsForValuesAffectingNumberOfSuccesses;
{
    return [NSSet setWithObject:@"state"];
}

+ (NSSet *)keyPathsForValuesAffectingProgress;
{
    return [NSSet setWithObject:@"state"];
}

- (NSUInteger)numberOfErrors;          { return [self state] == CDRExampleStateError;   }
- (NSUInteger)numberOfFailures;        { return [self state] == CDRExampleStateFailed;  }
- (NSUInteger)numberOfPendingExamples; { return [self state] == CDRExampleStatePending; }
- (NSUInteger)numberOfSuccesses;       { return [self state] == CDRExampleStatePassed;  }
- (NSUInteger)numberOfExamples;        { return 1; }

- (CDRExampleState)state;              { return CDRExampleStatePending; }
- (float)progress                      { return (float)([self state] != CDRExampleStateIncomplete); }

@end

