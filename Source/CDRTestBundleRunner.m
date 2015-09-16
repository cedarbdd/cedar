#import <Foundation/Foundation.h>
#import "CDRFunctions.h"

@interface CDRTestBundleRunner : NSObject
@end

@implementation CDRTestBundleRunner

+ (void)load {
    if (!CDRGetTestBundleExtension()) {
        return; // we're not in a test bundle
    }
    CDRInjectIntoXCTestRunner();
}

@end
