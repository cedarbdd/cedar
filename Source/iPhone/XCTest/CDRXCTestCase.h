#import <Foundation/Foundation.h>

extern const char *CDRXSeedKey;
extern const char *CDRXTestInvocationsKey;
extern const char *CDRXSpecKey;
extern const char *CDRXDispatcherKey;
extern const char *CDRXExampleKey;
extern const char *CDRXSpecClassNameKey;

@interface CDRXCTestCase : NSObject
@end

@interface CDRXCTestCase (InheritedFromXCTestCase)

- (void)recordFailureWithDescription:(NSString *)description inFile:(NSString *)filename atLine:(NSUInteger)lineNumber expected:(BOOL)expected;

@end
