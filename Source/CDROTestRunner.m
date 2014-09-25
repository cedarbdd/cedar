#import "CDROTestRunner.h"
#import "CDRFunctions.h"

@interface CDROTestRunner ()
@end

@implementation CDROTestRunner

+ (void)load {
    if (!CDRGetTestBundleExtension()) {
        return; // we're not in a test bundle
    }
   CDRInjectIntoXCTestRunner();
}

@end
