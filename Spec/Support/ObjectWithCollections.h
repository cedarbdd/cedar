#import <Foundation/Foundation.h>
#import "CedarObservedObject.h"

@interface ObjectWithCollections : NSObject <CedarObservedObject>

@property (retain, nonatomic) NSMutableArray *array;
@property (retain, nonatomic) NSMutableSet *set;
@property (retain, nonatomic) NSMutableOrderedSet *orderedSet;
@property (retain, nonatomic) NSMutableArray *manualArray;
@property (retain, nonatomic) NSMutableSet *manualSet;

@end
