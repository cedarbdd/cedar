#import "CDRExampleBase.h"

@interface CDRExample : CDRExampleBase {
    CDRSpecBlock block_;
    CDRExampleState state_;
    NSString *message_;
}

@property (nonatomic, copy) NSString *message;

+ (id)exampleWithText:(NSString *)text andBlock:(CDRSpecBlock)block;
- (id)initWithText:(NSString *)text andBlock:(CDRSpecBlock)block;

- (NSString *)fullText;

@end
