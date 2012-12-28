#import <Foundation/Foundation.h>

typedef void (^CDRSpecBlock)(void);

@protocol CDRExampleParent

- (BOOL)shouldRun;

- (void)setUp;
- (CDRSpecBlock)subjectBlock;
- (void)tearDown;

@optional
- (BOOL)hasFullText;
- (NSString *)fullText;
- (NSMutableArray *)fullTextInPieces;

- (NSUInteger)stackAddress;
@end
