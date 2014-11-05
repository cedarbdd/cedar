#import "CDRExampleGroup.h"
#import "CDRReportDispatcher.h"

@interface CDRExampleGroup (Private)
- (void)startObservingExamples;
- (void)stopObservingExamples;
@end

@implementation CDRExampleGroup

@synthesize examples = examples_;
@synthesize subjectActionBlock = subjectActionBlock_;

+ (id)groupWithText:(NSString *)text {
    return [[[[self class] alloc] initWithText: text] autorelease];
}

- (id)initWithText:(NSString *)text {
    return [self initWithText:text isRoot:NO];
}

- (id)initWithText:(NSString *)text isRoot:(BOOL)isRoot {
    if (self = [super initWithText:text]) {
        beforeBlocks_ = [[NSMutableArray alloc] init];
        examples_ = [[NSMutableArray alloc] init];
        afterBlocks_ = [[NSMutableArray alloc] init];
        invariants_ = [[NSMutableArray alloc] init];
        isRoot_ = isRoot;
    }
    return self;
}

- (void)dealloc {
    [afterBlocks_ release];
    [examples_ release];
    [beforeBlocks_ release];
    [invariants_ release];
    self.subjectActionBlock = nil;
    [super dealloc];
}

#pragma mark Public interface
- (NSString *)description {
    return [NSString stringWithFormat:@"Example Group: \"%@\"", self.fullText];
}

- (CDRSpecBlock)subjectActionBlock {
    CDRSpecBlock parentSubjectActionBlock = self.parent.subjectActionBlock;
    if (subjectActionBlock_) {
        if (parentSubjectActionBlock) {
            @throw([NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:[NSString stringWithFormat:@"%@ has more than one subject action block", self]
                                         userInfo:nil]);
        } else {
            return subjectActionBlock_;
        }
    } else {
        return parentSubjectActionBlock;
    }
}

- (void)add:(CDRExampleBase *)example {
    example.parent = self;
    [examples_ addObject:example];
}

- (void)addBefore:(CDRSpecBlock)block {
    CDRSpecBlock blockCopy = [block copy];
    [beforeBlocks_ addObject:blockCopy];
    [blockCopy release];
}

- (void)addAfter:(CDRSpecBlock)block {
    CDRSpecBlock blockCopy = [block copy];
    [afterBlocks_ addObject:blockCopy];
    [blockCopy release];
}

- (void)addInvariant:(CDRExampleBase *)inv {
    CDRExampleBase * invCopy = [inv copy];
    invCopy.parent = self;
    [invariants_ addObject: invCopy];
    [invCopy release];
}

#pragma mark CDRExampleBase
- (CDRExampleState)state {
    if (0 == [examples_ count]) {
        return CDRExampleStatePending;
    }

    CDRExampleState aggregateState = CDRExampleStateIncomplete;
    for (CDRExampleBase *example in examples_) {
        aggregateState |= [example state];
    }
    return aggregateState;
}

- (float)progress {
    if (0 == [examples_ count]) {
        return 1.0;
    }

    float aggregateProgress = 0.0;
    for (CDRExampleBase *example in examples_) {
        aggregateProgress += [example progress];
    }
    for (CDRExampleBase *example in invariants_) {
        aggregateProgress += [example progress];
    }
    return aggregateProgress / ([examples_ count] + [invariants_ count]);
}


- (void)runWithDispatcher:(CDRReportDispatcher *)dispatcher {
    if (startDate_) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"Attempt to run example group twice: %@", [self fullText]]
                               userInfo:nil] raise];
    }

    [self collectInvariants];
    
    [dispatcher runWillStartExampleGroup:self];
    [startDate_ release];
    startDate_ = [[NSDate alloc] init];

    [self startObservingExamples];
    [examples_ makeObjectsPerformSelector:@selector(runWithDispatcher:) withObject:dispatcher];
    if ([examples_ count] > 0) {
        [invariants_ makeObjectsPerformSelector:@selector(runWithDispatcher:) withObject:dispatcher];
    }
    [self stopObservingExamples];

    [endDate_ release];
    endDate_ = [[NSDate alloc] init];
    [dispatcher runDidFinishExampleGroup:self];

    [beforeBlocks_ release]; beforeBlocks_ = nil;
    [afterBlocks_ release]; afterBlocks_ = nil;
    [invariants_ release]; invariants_ = nil;
    self.subjectActionBlock = nil;
}

- (BOOL)hasFocusedExamples {
    if (self.isFocused) {
        return YES;
        
    } else if ([self hasFocusedInvariant]) {
        [self forceFocus];
        return YES;
    }

    for (CDRExampleBase *example in examples_) {
        if ([example hasFocusedExamples]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasChildren {
    return [examples_ count] > 0;
}

#pragma mark CDRExampleParent
- (void)setUp {
    [parent_ setUp];
    for (CDRSpecBlock beforeBlock in beforeBlocks_) {
        beforeBlock();
    }
}

- (void)tearDown {
    for (CDRSpecBlock afterBlock in afterBlocks_) {
        afterBlock();
    }
    [parent_ tearDown];
}

- (BOOL)hasFullText {
    return !isRoot_;
}


#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self willChangeValueForKey:@"state"];
    [self didChangeValueForKey:@"state"];
}

#pragma mark Private interface

- (void)startObservingExamples {
    for (id example in examples_) {
        [example addObserver:self forKeyPath:@"state" options:0 context:NULL];
    }
    for (id example in invariants_) {
        [example addObserver:self forKeyPath:@"state" options:0 context:NULL];
    }
}

- (void)stopObservingExamples {
    for (id example in examples_) {
        [example removeObserver:self forKeyPath:@"state"];
    }
    for (id example in invariants_) {
        [example removeObserver:self forKeyPath:@"state"];
    }
}

- (void)collectInvariants {
    //Because of recursive call order for runWithDispatcher: all grandparent invariants have been propagated down to parent by the time [self collectInvariants] is called
    //So no recursive call is necessary
    if ([self.parent isKindOfClass:[CDRExampleGroup class]]) {
        for (id inv in ((CDRExampleGroup*)self.parent)->invariants_) {
            [self addInvariant: ((CDRExampleBase*)inv)];
        }
    }
}

- (BOOL)hasFocusedInvariant {
    for (CDRExampleBase *example in invariants_) {
        if ([example isFocused]) {
            return YES;
        }
    }
    return NO;
}

//An invariant is focused, so we need to propagate focus *down* the tree
- (void)forceFocus {
    self.focused = YES;
    for (id child in examples_) {
        if ([child isKindOfClass:[CDRExampleGroup class]]) {
            [child forceFocus];
        }
    }
}

@end
