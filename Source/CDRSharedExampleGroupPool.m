#import "CDRSharedExampleGroupPool.h"
#import "CDRSpec.h"
#import "CDRExampleGroup.h"
#import "CDRExample.h"


@interface CDRSharedExampleGroupPool ()

+ (NSMutableDictionary *)registeredSharedExampleGroups;

+ (Class)registeredClassForGroupName:(NSString *)groupName;
+ (void)registerClass:(Class)aClass forGroupName:(NSString *)groupName;

@end


@implementation CDRSharedExampleGroupPool

+ (NSMutableDictionary *)registeredSharedExampleGroups;
{
    static NSMutableDictionary *_registeredSharedExampleGroups = nil;
    
    if(_registeredSharedExampleGroups != nil) return _registeredSharedExampleGroups;
    
    @synchronized([CDRSharedExampleGroupPool class])
    {
        if(_registeredSharedExampleGroups == nil)
            _registeredSharedExampleGroups = [[NSMutableDictionary alloc] init];
    }
    
    return _registeredSharedExampleGroups;
}

+ (Class)registeredClassForGroupName:(NSString *)groupName;
{
    Class ret = Nil;
    
    @synchronized([CDRSharedExampleGroupPool class])
    {
        ret = [[self registeredSharedExampleGroups] objectForKey:groupName];
    }
    
    return ret;
}

+ (void)registerClass:(Class)aClass forGroupName:(NSString *)groupName;
{
    NSAssert([aClass isSubclassOfClass:[CDRSharedExampleGroupPool class]], @"The class %@ cannot be registered for shared example groups.");
    
    @synchronized([CDRSharedExampleGroupPool class])
    {
        [[self registeredSharedExampleGroups] setObject:aClass forKey:groupName];
    }
}

+ (void)runGroupForName:(NSString *)groupName withExample:(CDRSpec *)spec subject:(NSString *)subject context:(NSDictionary *(^)(void))context;
{
    CDRExampleGroup *parentGroup = [spec currentGroup];
    
    NSString *prepend = @"";
    
    if([subject length] > 0) prepend = [subject stringByAppendingString:@" "];
    
    [spec setCurrentGroup:[CDRExampleGroup groupWithText:[NSString stringWithFormat:@"%@(as %@)", prepend, groupName]]];
    [parentGroup add:[spec currentGroup]];
    
    CDRSharedExampleGroupPool *testingPool = [[[self registeredClassForGroupName:groupName] alloc] initWithSpec:spec forGroupWithName:groupName];
    [testingPool declareSharedExampleGroups];
    
    NSAssert(testingPool->_targetBlock != NULL, @"No group defined for name \"%@\".", groupName);
    
    [testingPool runWithContext:context];
    [testingPool release];
    
    [spec setCurrentGroup:parentGroup];
}

- (id)init
{
    // Creates a CDRSharedExampleGroupPool object that will only register the shared groups the class supports
    // When a group is selected for testing, a new instance of the class is created and run using the spec and the specified group name
    return [self initWithSpec:nil forGroupWithName:nil];
}

- (id)initWithSpec:(CDRSpec *)spec forGroupWithName:(NSString *)usedGroupName;
{
    if((self = [super init]))
    {
        _currentSpec = [spec retain];
        
        sharedExamplesFor =
        [^(NSString *groupName, CDRSharedExampleGroupBlock block)
         {
             /* You can call this cheating.
              * When the framework first runs, it registers all group names defined by custom subclasses defined by the developer.
              * It associates the custom subclass to a group name: one class can be registered for multiple groups.
              * When a group is used, the class of the group is instantiated, the group is passed in with the spec object running the test.
              * The group specs are reran, this time test blocks are constructed and when sharedExamplesFor block is called
              * it only sets the block associated to the group name.
              */
             if(_currentSpec != nil && [groupName isEqualToString:usedGroupName]) _targetBlock = [block copy];
             
             // The shared example group pool is only added to the global pool when no specs are ran for it yet
             if(_currentSpec == nil) [[self class] registerClass:[self class] forGroupName:groupName];
             
         } copy];
        
        if(_currentSpec != nil)
        {
            describe =
            [^(NSString *text, CDRSpecBlock block)
             {
                 CDRExampleGroup *parentGroup = [_currentSpec currentGroup];
                 
                 [_currentSpec setCurrentGroup:[CDRExampleGroup groupWithText:text]];
                 [parentGroup add:[_currentSpec currentGroup]];
                 
                 block();
                 [_currentSpec setCurrentGroup:parentGroup];
             } copy];
            
            beforeEach =
            [^(CDRSpecBlock block)
             {
                 [[_currentSpec currentGroup] addBefore:block];
             } copy];
            
            afterEach =
            [^(CDRSpecBlock block)
             {
                 [[_currentSpec currentGroup] addAfter:block];
             } copy];
            
            it =
            [^(NSString *text, CDRSpecBlock block)
             {
                 [[_currentSpec currentGroup] add:[CDRExample exampleWithText:text andBlock:block]];
             } copy];
            
            itShouldBehaveLike =
            [^(NSString *groupName)
             {
                 itShouldBehaveLikeWithContext(nil, groupName, ^ NSDictionary * { return [self sharedExampleContext]; });
             } copy];
            
            itShouldBehaveLikeWithContext =
            [^(NSString *subject, NSString *groupName, NSDictionary *(^context)(void))
             {
                 [CDRSharedExampleGroupPool runGroupForName:groupName withExample:_currentSpec subject:subject context:context];
             } copy];
        }
    }
    return self;
}

- (void)dealloc
{
    [_targetBlock                  release];
    
    [sharedExamplesFor             release];
    [describe                      release];
    [beforeEach                    release];
    [afterEach                     release];
    [it                            release];
    [itShouldBehaveLike            release];
    [itShouldBehaveLikeWithContext release];
    
    [super                 dealloc];
}

- (NSMutableDictionary *)sharedExampleContext
{
    return [_currentSpec sharedExampleContext];
}

- (void)runWithContext:(NSDictionary *(^)(void))context;
{
    NSAssert(_targetBlock != NULL, @"No group defined for name.");
    
    _targetBlock(context);
}

- (void)failWithException:(NSException *)exception {
    [[CDRSpecFailure specFailureWithReason:[exception reason]] raise];
}

@end
