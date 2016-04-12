#import "Cedar.h"

static BOOL conformantClassBeforeEachWasTriggered__ = NO;
static BOOL nonConformantClassBeforeEachWasTriggered__ = NO;
static BOOL conformantClassAfterEachWasTriggered__ = NO;
static BOOL nonConformantClassAfterEachWasTriggered__ = NO;

using namespace Cedar::Matchers;


@interface ClassThatDoesntConformToCDRHooks : NSObject
@end

@interface ClassThatConformsToCDRHooks : NSObject
@end

@interface ClassThatConformsToCDRHooks ()<CDRHooks>
@end

@implementation ClassThatConformsToCDRHooks
+ (void)beforeEach {
    conformantClassBeforeEachWasTriggered__ = YES;
}

+ (void)afterEach {
    conformantClassAfterEachWasTriggered__ = YES;
}
@end

@implementation ClassThatDoesntConformToCDRHooks
+ (void)beforeEach {
    nonConformantClassBeforeEachWasTriggered__ = YES;
}

+ (void)afterEach {
    nonConformantClassAfterEachWasTriggered__ = YES;
}
@end

void verifyAfterEachCalledAsExpected() {
    NSCAssert(conformantClassAfterEachWasTriggered__, @"Expected +[ClassThatConformsToCDRHooks afterEach] to be called, but it wasn't. (From %s)", __FILE__);
    NSCAssert(!nonConformantClassAfterEachWasTriggered__, @"Expected +[ClassThatDoesntConformToCDRHooks afterEach] to NOT be called, but it was. (From %s)", __FILE__);
}

SPEC_BEGIN(CDRHooksSpec)

describe(@"global beforeEach", ^{
    it(@"should run the +beforeEach before only for CDRHooks conformant classes", ^{
        expect(conformantClassBeforeEachWasTriggered__).to(be_truthy);
        expect(nonConformantClassBeforeEachWasTriggered__).to(be_falsy);
    });
});

describe(@"global afterEach", ^{
    it(@"should run after all specs", ^{
        atexit(verifyAfterEachCalledAsExpected);
    });
});

SPEC_END
