#import <Foundation/Foundation.h>

@class CDRExampleBase;

@interface CDROTestNamer : NSObject

- (NSString *)classNameForExample:(CDRExampleBase *)example;
- (NSString *)methodNameForExample:(CDRExampleBase *)example;

@end
