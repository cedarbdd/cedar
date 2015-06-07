#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "CedarObservedObject.h"

@interface ObjectWithProperty : NSObject <CedarObservedObject>

@property (nonatomic, assign) CGFloat floatProperty;
@property (nonatomic, assign) CGFloat manualFloatProperty;

@end
