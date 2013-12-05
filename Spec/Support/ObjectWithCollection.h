#import <Foundation/Foundation.h>

@interface ObjectWithCollection : NSObject
@property (retain) NSMutableArray *collection;

- (void) mutateCollection;
@end
