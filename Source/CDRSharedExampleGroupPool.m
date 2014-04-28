#import "CDRSharedExampleGroupPool.h"
#import "CDRSpecHelper.h"
#import "CDRSpec.h"
#import "CDRExampleGroup.h"
#import "CDRSpecFailure.h"

extern CDRSpec *CDR_currentSpec;

@interface CDRSpecHelper (CDRSharedExampleGroupPoolFriend)
@property (nonatomic, retain, readonly) NSMutableDictionary *sharedExampleGroups;
@end

void sharedExamplesFor(NSString *groupName, CDRSharedExampleGroupBlock block) {
    [[[CDRSpecHelper specHelper] sharedExampleGroups] setObject:[[block copy] autorelease] forKey:groupName];
}

void itShouldBehaveLike(NSString *groupName) {
    CDRSharedExampleGroupBlock sharedExampleGroupBlock = [[[CDRSpecHelper specHelper] sharedExampleGroups] objectForKey:groupName];
    if (!sharedExampleGroupBlock) {
        NSString *message = [NSString stringWithFormat:@"Unknown shared example group with description: '%@'", groupName];
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:message userInfo:nil] raise];
    }

    CDRExampleGroup *parentGroup = CDR_currentSpec.currentGroup;
    CDR_currentSpec.currentGroup = [CDRExampleGroup groupWithText:[NSString stringWithFormat:@"(as %@)", groupName]];
    [parentGroup add:CDR_currentSpec.currentGroup];

    sharedExampleGroupBlock([CDRSpecHelper specHelper].sharedExampleContext);
    CDR_currentSpec.currentGroup = parentGroup;
}

@implementation CDRSharedExampleGroupPool

- (void)failWithException:(NSException *)exception {
    [[CDRSpecFailure specFailureWithReason:[exception reason]] raise];
}

@end
