#import "CDRSpec.h"
#import "CDRExampleParent.h"

@interface SpecHelper : NSObject <CDRExampleParent>

+ (id)specHelper;

- (void)beforeEach;
- (void)afterEach;

@end
