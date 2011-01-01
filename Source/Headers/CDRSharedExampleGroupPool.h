#import <Foundation/Foundation.h>
#import <Cedar/CDRSpec.h>

typedef void (^CDRSharedExampleGroupBlock)(NSDictionary *(^)(void));

// Simplifies context creation for itShouldBehaveLikeWithContext()
#ifndef MAKE_CONTEXT
#define MAKE_CONTEXT(context) ^ NSDictionary * { return context; }
#endif

@interface CDRSharedExampleGroupPool : NSObject
{
@private
    CDRSharedExampleGroupBlock  _targetBlock;
    CDRSpec                    *_currentSpec;
@protected
    void (^sharedExamplesFor)(NSString *, CDRSharedExampleGroupBlock);
    void (^describe)(NSString *, CDRSpecBlock);
    
    void (^beforeEach)(CDRSpecBlock);
    void (^afterEach)(CDRSpecBlock);
    
    void (^it)(NSString *, CDRSpecBlock);
    void (^itShouldBehaveLike)(NSString *);
    void (^itShouldBehaveLikeWithContext)(NSString *subject, NSString *groupName, NSDictionary *(^context)(void));
}

+ (void)runGroupForName:(NSString *)groupName withExample:(CDRSpec *)spec subject:(NSString *)subject context:(NSDictionary *(^)(void))context;

@property(nonatomic, retain, readonly) NSMutableDictionary *sharedExampleContext;

- (id)initWithSpec:(CDRSpec *)spec forGroupWithName:(NSString *)groupName;

- (void)runWithContext:(NSDictionary *(^)(void))context;

@end

@interface CDRSharedExampleGroupPool (SharedExampleGroupDeclaration)
- (void)declareSharedExampleGroups;
@end

#define SHARED_EXAMPLE_GROUPS_BEGIN(name)                                \
@interface SharedExampleGroupPoolFor##name : CDRSharedExampleGroupPool   \
@end                                                                     \
@implementation SharedExampleGroupPoolFor##name                          \
- (void)declareSharedExampleGroups {

#define SHARED_EXAMPLE_GROUPS_END                                        \
}                                                                        \
@end
