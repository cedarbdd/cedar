#import "Cedar.h"
#import "CDRSpec.h"
#import "CDRSpecRun.h"

static BOOL conformantClassBeforeEachWasTriggered__ = NO;
static BOOL conformantClassBeforeEachWasTriggeredBeforeSpecBeforeEach__ = NO;
static BOOL nonConformantClassBeforeEachWasTriggered__ = NO;
static BOOL conformantClassAfterEachWasTriggered__ = NO;
static BOOL conformantClassAfterEachWasTriggeredBeforeSpecAfterEach__ = NO;
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

@interface DummySpecForTestingHooks : CDRSpec
@end
@implementation DummySpecForTestingHooks
- (void)declareBehaviors {
    self.fileName = [NSString stringWithUTF8String:__FILE__];
    beforeEach(^{
        conformantClassBeforeEachWasTriggeredBeforeSpecBeforeEach__ = conformantClassBeforeEachWasTriggered__;
    });
    it(@"just needs to have a spec", ^{
    });
    afterEach(^{
        conformantClassAfterEachWasTriggeredBeforeSpecAfterEach__ = conformantClassAfterEachWasTriggered__;
    });
}
@end

SPEC_BEGIN(CDRHooksSpec)

//NB: If you focus any test here, you must also focus "just needs to run this spec" in DummySpecForTestingHooks
describe(@"CDRHooks", ^{
    beforeEach(^{
        nonConformantClassBeforeEachWasTriggered__ =
        nonConformantClassAfterEachWasTriggered__ =
        conformantClassBeforeEachWasTriggered__ =
        conformantClassBeforeEachWasTriggeredBeforeSpecBeforeEach__ =
        conformantClassAfterEachWasTriggered__ =
        conformantClassAfterEachWasTriggeredBeforeSpecAfterEach__ = NO;

        CDRSpec *dummySpec = [[[DummySpecForTestingHooks class] alloc] init];
        [dummySpec defineBehaviors];

        CDRSpecRun *specRun = [[CDRSpecRun alloc] initWithExampleReporters:@[]];
        [specRun performSpecRun:^{
            [dummySpec.rootGroup runWithDispatcher:specRun.dispatcher];
        }];
    });

    describe(@"+beforeEach", ^{
        it(@"should not call +beforeEach on non-conformant classes", ^{
            expect(nonConformantClassBeforeEachWasTriggered__).to(be_falsy);
        });

        it(@"should run the +beforeEach BEFORE spec beforeEaches for CDRHooks conformers", ^{
            expect(conformantClassBeforeEachWasTriggered__).to(be_truthy);
            expect(conformantClassBeforeEachWasTriggeredBeforeSpecBeforeEach__).to(be_truthy);
        });
    });

    describe(@"+afterEach", ^{
        it(@"should not call +afterEach on non-conformant classes", ^{
            expect(nonConformantClassAfterEachWasTriggered__).to(be_falsy);
        });

        it(@"should run the +afterEach AFTER spec afterEaches for CDRHooks conformers", ^{
            expect(conformantClassAfterEachWasTriggered__).to(be_truthy);
            expect(conformantClassAfterEachWasTriggeredBeforeSpecAfterEach__).to(be_falsy);
        });
    });
});

SPEC_END
