#import <Foundation/Foundation.h>

/// The methods on this class are mixed into dynamically-created XCTestCase subclasses that
/// are created at runtime for each CDRSpec.
@interface CDRXCTestCase : NSObject
@end

@interface CDRXCTestCase (InheritedFromXCTestCase)

- (void)recordFailureWithDescription:(NSString *)description inFile:(NSString *)filename atLine:(NSUInteger)lineNumber expected:(BOOL)expected;
+ (void)setTestInvocations:(NSArray *)array;

@end
