#import <Foundation/Foundation.h>

@class CedarDoubleImpl;

@interface CDRSpyInfo : NSObject

@property (nonatomic, assign) Class publicClass;
@property (nonatomic, assign) Class spiedClass;
@property (nonatomic, assign) id originalObject;
@property (nonatomic, retain) CedarDoubleImpl *cedarDouble;
@property (nonatomic, retain) NSMutableArray *callStack;

+ (void)storeSpyInfoForObject:(id)object;
+ (BOOL)clearSpyInfoForObject:(id)object;

+ (CDRSpyInfo *)spyInfoForObject:(id)object;
+ (CedarDoubleImpl *)cedarDoubleForObject:(id)object;
+ (Class)publicClassForObject:(id)object;

- (IMP)impForSelector:(SEL)selector;

- (BOOL)isInvocationRepeatedInCallStack:(NSInvocation *)invocation;
- (void)addToCallStack:(NSInvocation *)invocation;
- (void)popCallStack;

@end
