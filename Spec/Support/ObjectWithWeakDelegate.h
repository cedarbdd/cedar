#import <Foundation/Foundation.h>

@protocol ExampleDelegate <NSObject>

- (void)someMessage;

@end

@interface ObjectWithWeakDelegate : NSObject

@property (weak, nonatomic) id<ExampleDelegate> delegate;

- (void)tellTheDelegate;

@end
