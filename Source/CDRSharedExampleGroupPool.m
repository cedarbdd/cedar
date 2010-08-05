#import "CDRSharedExampleGroupPool.h"
#import "SpecHelper.h"
#import "CDRSpec.h"
#import "CDRExampleGroup.h"

extern CDRSpec *currentSpec;

@interface SpecHelper (CDRSharedExampleGroupPoolFriend)
- (NSMutableDictionary *)sharedExampleGroups;
@end

@implementation SpecHelper (CDRSharedExampleGroupPoolFriend)
- (NSMutableDictionary *)sharedExampleGroups {
    return sharedExampleGroups_;
}
@end


void sharedExamplesFor(NSString *groupName, CDRSharedExampleGroupBlock block) {
    [[[SpecHelper specHelper] sharedExampleGroups] setObject:[[block copy] autorelease] forKey:groupName];
}

void itShouldBehaveLike(NSString *groupName, NSDictionary *context) {
    CDRSharedExampleGroupBlock sharedExampleGroupBlock = [[[SpecHelper specHelper] sharedExampleGroups] objectForKey:groupName];

    CDRExampleGroup *parentGroup = currentSpec.currentGroup;
    currentSpec.currentGroup = [CDRExampleGroup groupWithText:[NSString stringWithFormat:@"(as %@)", groupName]];
    [parentGroup add:currentSpec.currentGroup];

    sharedExampleGroupBlock(context);
    currentSpec.currentGroup = parentGroup;
}

@implementation CDRSharedExampleGroupPool
@end
