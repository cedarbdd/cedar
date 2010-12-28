#import "CDRSpec.h"
#import "CDRExample.h"
#import "CDRExampleGroup.h"
#import "SpecHelper.h"

@interface SpecHelper (CDRSharedExampleGroupPoolFriend)
@property (nonatomic, retain, readonly) NSMutableDictionary *sharedExampleGroups;
@end

CDRSpec *currentSpec DEPRECATED_ATTRIBUTE;

void describe(NSString *text, CDRSpecBlock block) {
    /*
    CDRExampleGroup *parentGroup = currentSpec.currentGroup;
    currentSpec.currentGroup = [CDRExampleGroup groupWithText:text];
    [parentGroup add:currentSpec.currentGroup];

    block();
    currentSpec.currentGroup = parentGroup;
     */
}

void beforeEach(CDRSpecBlock block) {
    //[currentSpec.currentGroup addBefore:block];
}

void afterEach(CDRSpecBlock block) {
    //[currentSpec.currentGroup addAfter:block];
}

void it(NSString *text, CDRSpecBlock block) {
    //CDRExample *example = [CDRExample exampleWithText:text andBlock:block];
    //[currentSpec.currentGroup add:example];
}

void fail(NSString *reason) {
    //[[CDRSpecFailure specFailureWithReason:[NSString stringWithFormat:@"Failure: %@", reason]] raise];
}

@implementation CDRSpec

@synthesize currentGroup = currentGroup_, rootGroup = rootGroup_;

#pragma mark Memory
- (id)init
{
    if((self = [super init]))
    {
        rootGroup_ = [[CDRExampleGroup alloc] initWithText:[[self class] description]];
        self.currentGroup = rootGroup_;
        
        // FIXME: This is a temporary hack to pass SpecHelper tests however that class should be removed and replaced by more localized contexts...
        [rootGroup_ addBefore:^{ [[SpecHelper specHelper] setUp]; }];
        [rootGroup_ addAfter:^{ [[SpecHelper specHelper] tearDown]; }];
        
        describe =
        [[^(NSString *text, CDRSpecBlock block)
          {
              CDRExampleGroup *parentGroup = [self currentGroup];
              
              [self setCurrentGroup:[CDRExampleGroup groupWithText:text]];
              [parentGroup add:[self currentGroup]];
              
              block();
              [self setCurrentGroup:parentGroup];
          } copy] autorelease];
        
        beforeEach =
        [[^(CDRSpecBlock block)
          {
              [[self currentGroup] addBefore:block];
          } copy] autorelease];
        
        afterEach = 
        [[^(CDRSpecBlock block)
          {
              [[self currentGroup] addAfter:block];
          } copy] autorelease];
        
        it =
        [[^(NSString *text, CDRSpecBlock block)
          {
              [[self currentGroup] add:[CDRExample exampleWithText:text andBlock:block]];
          } copy] autorelease];
        
        fail =
        [[^(NSString *reason)
          {
              [[CDRSpecFailure specFailureWithReason:[NSString stringWithFormat:@"Failure: %@", reason]] raise];
          } copy] autorelease];
        
        itShouldBehaveLike =
        [[^(NSString *groupName)
          {
              CDRSharedExampleGroupPool *pool = [[[SpecHelper specHelper] sharedExampleGroups] objectForKey:groupName];
              
              [pool runGroupForName:groupName withExample:self];
          } copy] autorelease];
    }
    return self;
}

- (void)dealloc {
    self.rootGroup = nil;
    self.currentGroup = nil;

    [super dealloc];
}

- (void)defineBehaviors
{
    //currentSpec = self;
    [self declareBehaviors];
    //currentSpec = nil;
}

- (void)failWithException:(NSException *)exception {
    [[CDRSpecFailure specFailureWithReason:[exception reason]] raise];
}

@end
