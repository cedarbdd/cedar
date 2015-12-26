#import <Foundation/Foundation.h>
#import "CDRNullabilityCompat.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CDRSpecBlock)(void);

@protocol CDRExampleParent

- (BOOL)shouldRun;

- (void)setUp;
- (nullable CDRSpecBlock)subjectActionBlock;
- (void)tearDown;

@optional
- (BOOL)hasFullText;
- (NSString *)fullText;
- (NSMutableArray *)fullTextInPieces;

- (NSUInteger)stackAddress;
@end

NS_ASSUME_NONNULL_END
