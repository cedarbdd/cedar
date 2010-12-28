#import "CDRExampleGroup.h"

@interface CDRExampleGroup ()
- (void)CDR_startObservingExamples;
- (void)CDR_stopObservingExamples;

- (void)CDR_updateNumberOfExamples;
- (void)CDR_updateCountForExampleState:(CDRExampleState)state addValue:(NSInteger)added;

- (void)CDR_remove:(CDRExampleBase *)example;

@end

@implementation CDRExampleGroup

@synthesize examples = examples_;

+ (id)groupWithText:(NSString *)text
{
    return [[[[self class] alloc] initWithText:text] autorelease];
}

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithText:(NSString *)text
{
    if((self = [super initWithText:text]))
    {
        beforeBlocks_ = [[NSMutableArray alloc] init];
        examples_     = [[NSMutableArray alloc] init];
        afterBlocks_  = [[NSMutableArray alloc] init];
        
        _totalNeedsUpdate = YES;
    }
    return self;
}

- (void)dealloc
{
    [afterBlocks_  release];
    [examples_     release];
    [beforeBlocks_ release];
    [super         dealloc];
}

#pragma mark Public interface
- (NSString *)description
{
    return [NSString stringWithFormat:@"Example Group: %@", self.text];
}

- (void)add:(CDRExampleBase *)example
{
    [examples_ addObject:example];
    
    [[example parent] CDR_remove:example];
    
    [example setParent:self];
}

- (void)CDR_remove:(CDRExampleBase *)example;
{
    [example setParent:nil];
    [examples_ removeObject:example];
}

- (void)addBefore:(CDRSpecBlock)block
{
    CDRSpecBlock blockCopy = [block copy];
    [beforeBlocks_ addObject:blockCopy];
    [blockCopy release];
}

- (void)addAfter:(CDRSpecBlock)block
{
    CDRSpecBlock blockCopy = [block copy];
    [afterBlocks_ addObject:blockCopy];
    [blockCopy release];
}

#pragma mark CDRExampleBase states
- (CDRExampleState)state
{
    if(0 == [examples_ count]) return CDRExampleStatePending;
    
    if(_errorExamples + _failedExamples + _pendingExamples + _successfulExamples < [examples_ count])
        return CDRExampleStateIncomplete;
    
    if(0 != _errorExamples)    return CDRExampleStateError;
    
    if(0 != _failedExamples)   return CDRExampleStateFailed;
    
    if(0 != _pendingExamples)  return CDRExampleStatePending;
    
    if([examples_ count] == _successfulExamples) return CDRExampleStatePassed;
    
    return CDRExampleStateIncomplete;
}

- (float)progress
{
    if(0 == [examples_ count]) return 1.0;
    
    float aggregateProgress = 0.0;
    
    for(CDRExampleBase *example in examples_)
        aggregateProgress += [example progress];
    
    return aggregateProgress / [examples_ count];
}

- (NSUInteger)numberOfErrors;          { return _errorExamples;      }
- (NSUInteger)numberOfFailures;        { return _failedExamples;     }
- (NSUInteger)numberOfPendingExamples; { return _pendingExamples;    }
- (NSUInteger)numberOfSuccesses;       { return _successfulExamples; }

- (void)CDR_updateNumberOfExamples;
{
    NSUInteger count = 0;
    
    if([self hasChildren])
        for(CDRExampleBase *example in examples_)
            count += [example numberOfExamples];
    else
    {
        count = 1;
        
        [self willChangeValueForKey:@"numberOfPendingExamples"];
        _pendingExamples = 1;
        [self didChangeValueForKey:@"numberOfPendingExamples"];
    }
    
    if(_totalExamples != count)
    {
        [self willChangeValueForKey:@"numberOfExamples"];
        _totalExamples = count;
        [self didChangeValueForKey:@"numberOfExamples"];
    }
    
    _totalNeedsUpdate = NO;
}

- (NSUInteger)numberOfExamples;
{
    if(_totalNeedsUpdate) [self CDR_updateNumberOfExamples];
    
    return _totalExamples;
}

#pragma mark Tests

- (void)run
{
    [self CDR_startObservingExamples];
    [examples_ makeObjectsPerformSelector:@selector(run)];
    [self CDR_stopObservingExamples];
}

- (BOOL)hasChildren
{
    return [examples_ count] > 0;
}

- (BOOL)isRoot;
{
    return [self parent] == nil;
}

#pragma mark -
#pragma mark CDRExampleParent
- (void)setUp
{
    [parent_ setUp];
    for(CDRSpecBlock beforeBlock in beforeBlocks_) beforeBlock();
}

- (void)tearDown
{
    for(CDRSpecBlock afterBlock in afterBlocks_) afterBlock();
    [parent_ tearDown];
}

#pragma mark -
#pragma mark Key-Value Observing

- (void)CDR_updateCountForExampleState:(CDRExampleState)state addValue:(NSInteger)added;
{
    NSUInteger *target = NULL;
    NSString   *key    = nil;
    
    switch(state)
    {
        case CDRExampleStateIncomplete : /* incomplete states are not counted */ break;
        case CDRExampleStateError      : target = &_errorExamples;      key = @"numberOfErrors";          break;
        case CDRExampleStateFailed     : target = &_failedExamples;     key = @"numberOfFailures";        break;
        case CDRExampleStatePending    : target = &_pendingExamples;    key = @"numberOfPendingExamples"; break;
        case CDRExampleStatePassed     : target = &_successfulExamples; key = @"numberOfSuccesses";       break;
    }
    
    if(target != NULL)
    {
        [self willChangeValueForKey:key];
        *target += added;
        [self didChangeValueForKey:key];
    }
}

static NSString        *const CDRExampleStateChangedContext = @"CDRExampleStateChangedContext";
static CDRExampleState  const CDRExampleStatePassedContext  = CDRExampleStatePassed;
static CDRExampleState  const CDRExampleStatePendingContext = CDRExampleStatePending;
static CDRExampleState  const CDRExampleStateFailedContext  = CDRExampleStateFailed;
static CDRExampleState  const CDRExampleStateErrorContext   = CDRExampleStateError;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(context == CDRExampleStateChangedContext)
    {
        [self willChangeValueForKey:@"state"];
        [self didChangeValueForKey:@"state"];
    }
    else if(context != NULL)
    {
        [self CDR_updateCountForExampleState:*(CDRExampleState *)context addValue:-[[change objectForKey:NSKeyValueChangeOldKey] integerValue]];
        [self CDR_updateCountForExampleState:*(CDRExampleState *)context addValue: [[change objectForKey:NSKeyValueChangeNewKey] integerValue]];
    }
}

- (void)CDR_startObservingExamples
{
    NSIndexSet *allIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [examples_ count])];
    
    [examples_ addObserver:self toObjectsAtIndexes:allIndexes forKeyPath:@"state" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial context:CDRExampleStateChangedContext];
    
    [examples_ addObserver:self toObjectsAtIndexes:allIndexes forKeyPath:@"numberOfErrors"          options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial context:(void *)&CDRExampleStateErrorContext  ];
    [examples_ addObserver:self toObjectsAtIndexes:allIndexes forKeyPath:@"numberOfFailures"        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial context:(void *)&CDRExampleStateFailedContext ];
    [examples_ addObserver:self toObjectsAtIndexes:allIndexes forKeyPath:@"numberOfPendingExamples" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial context:(void *)&CDRExampleStatePendingContext];
    [examples_ addObserver:self toObjectsAtIndexes:allIndexes forKeyPath:@"numberOfSuccesses"       options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial context:(void *)&CDRExampleStatePassedContext ];
}

- (void)CDR_stopObservingExamples
{
    NSIndexSet *allIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [examples_ count])];
    
    [examples_ removeObserver:self fromObjectsAtIndexes:allIndexes forKeyPath:@"state"                  ];
    
    [examples_ removeObserver:self fromObjectsAtIndexes:allIndexes forKeyPath:@"numberOfErrors"         ];
    [examples_ removeObserver:self fromObjectsAtIndexes:allIndexes forKeyPath:@"numberOfFailures"       ];
    [examples_ removeObserver:self fromObjectsAtIndexes:allIndexes forKeyPath:@"numberOfPendingExamples"];
    [examples_ removeObserver:self fromObjectsAtIndexes:allIndexes forKeyPath:@"numberOfSuccesses"      ];
}

@end
