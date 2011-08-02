#import "CDRSpec.h"
#import "CDRExample.h"
#import "CDRExampleGroup.h"
#import "CDRSpecFailure.h"
#import "SpecHelper.h"

CDRSpec *currentSpec;

void describe(NSString *text, CDRSpecBlock block) {
    CDRExampleGroup *parentGroup = currentSpec.currentGroup;
    currentSpec.currentGroup = [CDRExampleGroup groupWithText:text];
    [parentGroup add:currentSpec.currentGroup];

    block();
    currentSpec.currentGroup = parentGroup;
}

void beforeEach(CDRSpecBlock block) {
    [currentSpec.currentGroup addBefore:block];
}

void afterEach(CDRSpecBlock block) {
    [currentSpec.currentGroup addAfter:block];
}

void it(NSString *text, CDRSpecBlock block) {
    CDRExample *example = [CDRExample exampleWithText:text andBlock:block];
    [currentSpec.currentGroup add:example];
}

void fail(NSString *reason) {
    [[CDRSpecFailure specFailureWithReason:[NSString stringWithFormat:@"Failure: %@", reason]] raise];
}

void context(NSString *text, CDRSpecBlock block) {
    describe(text, block);
}

void xcontext(NSString *text, CDRSpecBlock block) {
    it(text, PENDING);
}

void xdescribe(NSString *text, CDRSpecBlock block) {
    it(text, PENDING);
}

void xit(NSString *text, CDRSpecBlock block) {
    it(text, PENDING);
}

@implementation CDRSpec

@synthesize currentGroup = currentGroup_, rootGroup = rootGroup_;

#pragma mark Memory
- (id)init {
    if (self = [super init]) {
        self.rootGroup = [[[CDRExampleGroup alloc] initWithText:[[self class] description] isRoot:YES] autorelease];
        self.rootGroup.parent = [SpecHelper specHelper];
        self.currentGroup = self.rootGroup;
    }
    return self;
}

- (void)dealloc {
    self.rootGroup = nil;
    self.currentGroup = nil;

    [super dealloc];
}

- (void)defineBehaviors {
    currentSpec = self;
    [self declareBehaviors];
    currentSpec = nil;
}

- (void)failWithException:(NSException *)exception {
    [[CDRSpecFailure specFailureWithReason:[exception reason]] raise];
}

@end
