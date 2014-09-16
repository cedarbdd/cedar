#import "CDROTestRunner.h"
#import "CDROTestHelper.h"
#import "CDRFunctions.h"

@interface CDROTestRunner ()
@property (nonatomic) int exitStatus;
@end

@implementation CDROTestRunner

#if !TARGET_OS_IPHONE
+ (void)load {
    CDRHijackOCUnitAndXCTestRun((IMP)CDRRunTests);
}
#endif

@end
