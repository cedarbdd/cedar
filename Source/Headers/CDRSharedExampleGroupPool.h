#import <Foundation/Foundation.h>
#import "CDRSpec.h"

typedef void (^CDRSharedExampleGroupBlock)(NSDictionary *);

@interface CDRSharedExampleGroupPool : NSObject
{
    NSMutableDictionary *_groups;
    CDRSpec             *_currentSpec;
@protected
    void (^sharedExamplesFor)(NSString *, CDRSharedExampleGroupBlock);
    void (^describe)(NSString *, CDRSpecBlock);
    
    void (^beforeEach)(CDRSpecBlock);
    void (^afterEach)(CDRSpecBlock);
    
    void (^it)(NSString *, CDRSpecBlock);
    void (^itShouldBehaveLike)(NSString *);
    
    void (^fail)(NSString *);
}

- (void)runGroupForName:(NSString *)groupName withExample:(CDRSpec *)spec;

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
