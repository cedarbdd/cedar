#import "CDROTestRunner.h"
#import "CDROTestHelper.h"
#import "CDRFunctions.h"

@interface CDROTestRunner ()
@property (nonatomic) int exitStatus;
@end

@implementation CDROTestRunner

+ (void)load {
    CDRHijackOCUnitAndXCTestRun((IMP)CDRRunTests);
}

@end
