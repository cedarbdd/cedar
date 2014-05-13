#import <Foundation/Foundation.h>

@protocol BazProtocol<NSObject>
@end

@interface FooSuperclass : NSObject
@end

@interface BarSubclass : FooSuperclass
@end

@interface QuuxSubclass : FooSuperclass <BazProtocol>
@end
