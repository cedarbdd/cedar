#import "CDRSharedExampleGroupPool.h"
#import "SpecHelper.h"
#import "CDRSpec.h"
#import "CDRExampleGroup.h"
#import "CDRExample.h"

@interface SpecHelper (CDRSharedExampleGroupPoolFriend)
@property (nonatomic, retain, readonly) NSMutableDictionary *sharedExampleGroups;
@end


@implementation CDRSharedExampleGroupPool

- (id)init
{
    if((self = [super init]))
    {
        _groups = [[NSMutableDictionary alloc] init];
        
        sharedExamplesFor =
        [[^(NSString *groupName, CDRSharedExampleGroupBlock block)
          {
              [_groups setObject:[[block copy] autorelease] forKey:groupName];
              [[[SpecHelper specHelper] sharedExampleGroups] setObject:self forKey:groupName];
          } copy] autorelease];
        
        describe =
        [[^(NSString *text, CDRSpecBlock block)
          {
              CDRExampleGroup *parentGroup = [_currentSpec currentGroup];
              
              [_currentSpec setCurrentGroup:[CDRExampleGroup groupWithText:text]];
              [parentGroup add:[_currentSpec currentGroup]];
              
              block();
              [_currentSpec setCurrentGroup:parentGroup];
          } copy] autorelease];
        
        beforeEach =
        [[^(CDRSpecBlock block)
          {
              [[_currentSpec currentGroup] addBefore:block];
          } copy] autorelease];
        
        afterEach = 
        [[^(CDRSpecBlock block)
          {
              [[_currentSpec currentGroup] addAfter:block];
          } copy] autorelease];
        
        it =
        [[^(NSString *text, CDRSpecBlock block)
          {
              [[_currentSpec currentGroup] add:[CDRExample exampleWithText:text andBlock:block]];
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
              
              [pool runGroupForName:groupName withExample:_currentSpec];
          } copy] autorelease];
    }
    return self;
}

- (void)dealloc
{
    [_groups release];
    [super dealloc];
}


- (void)runGroupForName:(NSString *)groupName withExample:(CDRSpec *)spec
{
    CDRSpec *previousSpec = _currentSpec;
    
    _currentSpec = spec;
    
    CDRSharedExampleGroupBlock sharedExampleGroupBlock = [_groups objectForKey:groupName];
    
    NSAssert(sharedExampleGroupBlock != NULL, @"No group defined for name \"%@\"", groupName);
    
    CDRExampleGroup *parentGroup = [_currentSpec currentGroup];
    [_currentSpec setCurrentGroup:[CDRExampleGroup groupWithText:[NSString stringWithFormat:@"(as %@)", groupName]]];
    [parentGroup add:[_currentSpec currentGroup]];
    
    sharedExampleGroupBlock([[SpecHelper specHelper] sharedExampleContext]);
    [_currentSpec setCurrentGroup:parentGroup];
    
    _currentSpec = previousSpec;
}

- (void)failWithException:(NSException *)exception {
    [[CDRSpecFailure specFailureWithReason:[exception reason]] raise];
}

@end
