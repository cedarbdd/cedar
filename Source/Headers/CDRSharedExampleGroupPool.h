#import <Foundation/Foundation.h>

#define CDR_OVERLOADABLE __attribute__((overloadable))

@protocol CDRSharedExampleGroupPool
@end

typedef void (^CDRSharedExampleGroupBlock)(NSDictionary *);
typedef void (^CDRSharedExampleContextProviderBlock)(NSMutableDictionary *);

#ifdef __cplusplus
extern "C" {
#endif
void sharedExamplesFor(NSString *, CDRSharedExampleGroupBlock);
CDR_OVERLOADABLE void itShouldBehaveLike(NSString *);
CDR_OVERLOADABLE void itShouldBehaveLike(NSString *, CDRSharedExampleContextProviderBlock);
#ifdef __cplusplus
}
#endif

@interface CDRSharedExampleGroupPool : NSObject <CDRSharedExampleGroupPool>
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
