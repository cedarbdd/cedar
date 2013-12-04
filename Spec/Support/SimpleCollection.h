#import <Foundation/Foundation.h>

@interface SimpleCollection : NSObject
@property (retain) NSMutableArray *collection;

- (void) mutateCollection;
@end
