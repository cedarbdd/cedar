#import <Foundation/Foundation.h>

@interface CDRXCTestCase : NSObject
@end

@interface CDRXCTestCase (InheritedFromXCTestCase)

- (void)recordFailureWithDescription:(NSString *)description inFile:(NSString *)filename atLine:(NSUInteger)lineNumber expected:(BOOL)expected;
+ (void)setTestInvocations:(NSArray *)array;

@end
