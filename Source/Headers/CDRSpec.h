#import <Foundation/Foundation.h>
#import <Cedar/CDRExampleBase.h>

@protocol CDRExampleReporter;
@class CDRExampleGroup, SpecHelper;

extern CDRSpecBlock PENDING;

#ifdef __cplusplus
extern "C" {
#endif
    void fail(NSString *);
#ifdef __cplusplus
}
#endif

// Simplifies context creation for itShouldBehaveLikeWithContext()
#ifndef MAKE_CONTEXT
#define MAKE_CONTEXT(context) ^ NSDictionary * { return context; }
#endif

@interface CDRSpec : NSObject
{
@private
    CDRExampleGroup     *rootGroup_;
    CDRExampleGroup     *currentGroup_;
    NSMutableDictionary *_sharedExampleContext;
@protected
    void (^describe)(NSString *, CDRSpecBlock);
    
    void (^beforeEach)(CDRSpecBlock);
    void (^afterEach)(CDRSpecBlock);
    
    void (^it)(NSString *, CDRSpecBlock);
    void (^itShouldBehaveLike)(NSString *);
    void (^itShouldBehaveLikeWithContext)(NSString *subject, NSString *groupName, NSDictionary *(^context)(void));
}

@property(nonatomic, retain, readonly) NSMutableDictionary *sharedExampleContext;
@property(nonatomic, retain) CDRExampleGroup *currentGroup, *rootGroup;

- (void)defineBehaviors;

@end

@interface CDRSpec (SpecDeclaration)
- (void)declareBehaviors;
@end

#define SPEC_BEGIN(name)             \
@interface name : CDRSpec            \
@end                                 \
@implementation name                 \
- (void)declareBehaviors {

#define SPEC_END                     \
}                                    \
@end

#define DESCRIBE(name)               \
@interface name##Spec : CDRSpec      \
@end                                 \
@implementation name##Spec           \
- (void)declareBehaviors

#define DESCRIBE_END                 \
@end
