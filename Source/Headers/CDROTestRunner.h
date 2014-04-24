#import <Foundation/Foundation.h>

@interface CDROTestRunner : NSObject

- (void)runAllTestsWithTestProbe:(id)testProbe;

@end

@interface CDROTestRunner (ProtectedMethods)

- (void)runStandardTestsWithTestProbe:(id)testProbe;
- (void)runSpecs;

- (void)recordExitStatus:(int)status;
- (void)exitWithAggregateStatus;
- (void)exitWithStatus:(int)status;

@end
