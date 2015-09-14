#import <Foundation/Foundation.h>

@interface CDRRuntimeUtilities : NSObject

+ (Class)createMixinSubclassOf:(Class)parentClass newClassName:(NSString *)newClassName templateClass:(Class)templateClass;

@end
