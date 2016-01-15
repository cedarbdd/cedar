#import "Cedar.h"
#import "SimpleIncrementer.h"

#if !__has_feature(objc_arc)
#error This spec must be compiled with ARC to work properly
#endif

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SHARED_EXAMPLE_GROUPS_BEGIN(CedarDoubleARCSharedExamples)

sharedExamplesFor(@"a Cedar double when used with ARC", ^(NSDictionary *sharedContext) {
    __block id<CedarDouble, SimpleIncrementer> myDouble;

    beforeEach(^{
        myDouble = [sharedContext objectForKey:@"double"];
    });

    context(@"when recording an invocation", ^{
        context(@"inside an async block", ^{
            it(@"should complete happily", ^{
                __block bool called = false;
                myDouble stub_method("methodWithBlock:").and_do(^(NSInvocation *invocation) {
                    void (^runBlock)();
                    [invocation getArgument:&runBlock atIndex:2];
                    runBlock();
                    called = true;
                });

                dispatch_group_t group = dispatch_group_create();
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);

                dispatch_group_async(group, queue, ^{
                    dispatch_group_enter(group);
                    [myDouble methodWithBlock:^{
                        dispatch_group_leave(group);
                    }];
                });

                dispatch_group_notify(group, queue, ^{
                    [myDouble methodWithBlock:^{ }];
                });

                while (!called) {
                    NSDate *futureDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
                    [[NSRunLoop currentRunLoop] runUntilDate:futureDate];
                }

                myDouble should have_received("methodWithBlock:");
                [myDouble reset_sent_messages];
            });
        });
    });
});

SHARED_EXAMPLE_GROUPS_END
