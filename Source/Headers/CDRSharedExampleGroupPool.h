#import <Foundation/Foundation.h>
#import "CDRSpec.h"

typedef void (^CDRSharedExampleGroupBlock)(NSDictionary *);

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
}

+ (void)runGroupForName:(NSString *)groupName withExample:(CDRSpec *)spec;

@property(nonatomic, retain, readonly) NSMutableDictionary *sharedExampleContext;

- (id)initWithSpec:(CDRSpec *)spec forGroupWithName:(NSString *)groupName;

- (void)run;

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
