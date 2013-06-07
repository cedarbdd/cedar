#import <Foundation/Foundation.h>

@class CedarDoubleImpl;

@interface CDRSpyInfo : NSObject

@property (nonatomic, assign) Class originalClass;
@property (nonatomic, assign) id originalObject;
@property (nonatomic, retain) CedarDoubleImpl *cedarDouble;

+ (void)storeSpyInfoForObject:(id)originalObject;

+ (CedarDoubleImpl *)cedarDoubleForObject:(id)originalObject;
+ (Class)originalClassForObject:(id)originalObject;

@end
