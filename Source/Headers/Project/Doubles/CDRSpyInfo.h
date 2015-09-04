#import <Foundation/Foundation.h>

@class CedarDoubleImpl;

@interface CDRSpyInfo : NSObject

@property (nonatomic, assign) Class publicClass;
@property (nonatomic, assign) Class spiedClass;
@property (nonatomic, retain) CedarDoubleImpl *cedarDouble;

+ (void)storeSpyInfoForObject:(id)object;
+ (BOOL)clearSpyInfoForObject:(id)object;

+ (CDRSpyInfo *)spyInfoForObject:(id)object;
+ (CedarDoubleImpl *)cedarDoubleForObject:(id)object;
+ (Class)publicClassForObject:(id)object;

- (IMP)impForSelector:(SEL)selector;

@end
