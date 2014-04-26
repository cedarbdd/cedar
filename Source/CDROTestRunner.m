#import "CDROTestRunner.h"
#import "CDROTestHelper.h"
#import "CDRFunctions.h"

@interface CDROTestRunner ()
@property (nonatomic) int exitStatus;
@end

@implementation CDROTestRunner

#if !TARGET_OS_IPHONE
void CDRRunTests(id self, SEL _cmd, id object) {
    CDROTestRunner *runner = [[CDROTestRunner alloc] init];
    [runner runAllTestsWithTestProbe:self];
}

+ (void)load {
    CDRHijackOCUnitAndXCTestRun((IMP)CDRRunTests);
}
#endif

- (void)runAllTestsWithTestProbe:(id)testProbe {
    [self runStandardTestsWithTestProbe:testProbe];
    [self runSpecs];

    // otest always returns 0 as its exit code even if any test fails;
    // we need to forcibly exit with correct exit code to make CI happy.
    [self exitWithAggregateStatus];
}

- (void)runStandardTestsWithTestProbe:(id)testProbe {
    int exitStatus;
    if (CDRIsXCTest()) {
        exitStatus = CDRRunXCUnitTests(testProbe);
    } else {
        exitStatus = CDRRunOCUnitTests(testProbe);
    }
    [self recordExitStatus:exitStatus];
}

- (void)runSpecs {
    int exitStatus = CDRRunSpecs();
    [self recordExitStatus:exitStatus];
}

- (void)recordExitStatus:(int)status {
    self.exitStatus |= status;
}

- (void)exitWithAggregateStatus {
    [self exitWithStatus:self.exitStatus];
}

- (void)exitWithStatus:(int)status {
    fflush(stdout);
    fflush(stderr);
    fclose(stdout);
    fclose(stderr);

    exit(status);
}

@end
