#import <Foundation/Foundation.h>

@interface CDRTypeUtilities : NSObject
+ (NSString *)typeNameForEncoding:(const char *)encoding;
+ (id)boxedObjectOfBytes:(const char *)argBuffer ofObjCType:(const char *)argType;
@end
