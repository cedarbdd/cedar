#import "CDRSpec.h"
#import "CDRExampleParent.h"

@interface SpecHelper : NSObject <CDRExampleParent>

- (void)beforeEach;
- (void)afterEach;

@end

extern SpecHelper *specHelper;
