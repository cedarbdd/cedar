#import <Foundation/Foundation.h>
#import "CedarObservedObject.h"

@interface ObjectWithProperty : NSObject <CedarObservedObject>

@property (nonatomic, assign) CGFloat floatProperty;

@end
