#import "CDROTestRunner.h"
#import "CDRFunctions.h"

@interface CDROTestRunner ()
@end

@implementation CDROTestRunner

+ (void)load {
    CDRInjectIntoXCTestRunner();
}

@end
