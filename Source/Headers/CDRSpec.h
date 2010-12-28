#import <Foundation/Foundation.h>
#import "CDRExampleBase.h"

@protocol CDRExampleReporter;
@class CDRExampleGroup, SpecHelper;

extern CDRSpecBlock PENDING;

@interface CDRSpec : NSObject
{
@private
    CDRExampleGroup *rootGroup_;
    CDRExampleGroup *currentGroup_;
@protected
    void (^describe)(NSString *, CDRSpecBlock);
    
    void (^beforeEach)(CDRSpecBlock);
    void (^afterEach)(CDRSpecBlock);
    
    void (^it)(NSString *, CDRSpecBlock);
    void (^itShouldBehaveLike)(NSString *);
    
    void (^fail)(NSString *);
}

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
