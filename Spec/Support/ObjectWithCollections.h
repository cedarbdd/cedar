#import <Foundation/Foundation.h>
#import "CedarObservedObject.h"

@interface ObjectWithCollections : NSObject <CedarObservedObject>

@property (retain) NSMutableArray *array;
@property (retain) NSMutableSet *set;
@property (retain) NSMutableOrderedSet *orderedSet;

@end
