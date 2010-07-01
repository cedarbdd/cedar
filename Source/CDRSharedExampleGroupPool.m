#import "CDRSharedExampleGroupPool.h"
#import "SpecHelper.h"

@interface SpecHelper (CDRSharedExampleGroupPoolFriend)
- (NSMutableDictionary *)sharedExampleGroups;
@end

@implementation SpecHelper (CDRSharedExampleGroupPoolFriend)
- (NSMutableDictionary *)sharedExampleGroups {
    return sharedExampleGroups_;
}
@end


void sharedExamplesFor(NSString *groupName, CDRSharedExampleGroupBlock block) {
    [[[SpecHelper specHelper] sharedExampleGroups] setObject:[block copy] forKey:groupName];
}

void itShouldBehaveLike(NSString *groupName, NSDictionary *context) {
    CDRSharedExampleGroupBlock sharedExampleGroupBlock = [[[SpecHelper specHelper] sharedExampleGroups] objectForKey:groupName];
    sharedExampleGroupBlock(context);
}

@implementation CDRSharedExampleGroupPool
@end
