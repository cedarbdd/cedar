#import <Cedar/SpecHelper.h>
#import "SimpleIncrementer.h"

extern "C" {
#import "ExpectFailureWithMessage.h"
}

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;
using namespace Cedar::Doubles::Arguments;

SPEC_BEGIN(SpyOnSpec)

describe(@"spy_on", ^{
    __block SimpleIncrementer *incrementer;

    beforeEach(^{
        incrementer = [[[SimpleIncrementer alloc] init] autorelease];
        spy_on(incrementer);

        [[SpecHelper specHelper].sharedExampleContext setObject:incrementer forKey:@"double"];
    });

    describe(@"method stubbing", ^{
        NSNumber *arg1 = @1;
        NSNumber *arg2 = @2;
        NSNumber *arg3 = @3;
        NSNumber *returnValue = @4;

        context(@"with a specific argument value", ^{
            context(@"when invoked with a parameter of non-matching value", ^{
                beforeEach(^{
                    incrementer stub_method("methodWithNumber1:andNumber2:").with(arg1, arg2).and_return(returnValue);
                });

                it(@"should not raise an exception", ^{
                    ^{ [incrementer methodWithNumber1:arg1 andNumber2:arg3]; } should_not raise_exception;
                });

                it(@"should invoke the original method", ^{
                    [incrementer methodWithNumber1:arg1 andNumber2:arg3] should equal([arg1 floatValue] * [arg3 floatValue]);
                });
            });
        });

        context(@"with a nil argument", ^{
            beforeEach(^{
                incrementer stub_method("incrementByNumber:").with(nil);
            });

            context(@"when invoked with a non-nil argument", ^{
                beforeEach(^{
                    [incrementer incrementByNumber:@123];
                });

                it(@"should invoke the original method", ^{
                    incrementer.value should equal(123);
                });
            });
        });

        context(@"with an argument specified as any instance of a specified class", ^{
            NSNumber *arg = @123;

            beforeEach(^{
                incrementer stub_method("methodWithNumber1:andNumber2:").with(any([NSDecimalNumber class]), arg).and_return(@99);
            });

            context(@"when invoked with the incorrect class", ^{
                it(@"should invoke the original method", ^{
                    [incrementer methodWithNumber1:@2 andNumber2:arg] should equal(2 * [arg floatValue]);
                });
            });

            context(@"when invoked with nil", ^{
                it(@"should invoke the original method", ^{
                    [incrementer methodWithNumber1:nil andNumber2:arg] should equal(0);
                });
            });
        });
    });

    itShouldBehaveLike(@"a Cedar double");
    itShouldBehaveLike(@"a Cedar double when used with ARC");

    it(@"should blow up in an obvious manner when spying on nil", ^{
        ^{ spy_on(nil); } should raise_exception.with_reason(@"Cannot spy on nil");
    });

    it(@"should not change the functionality of the given object", ^{
        [incrementer increment];
        incrementer.value should equal(1);
    });

    it(@"should not change the methods the given object responds to", ^{
        [incrementer respondsToSelector:@selector(increment)] should be_truthy;
        [incrementer respondsToSelector:@selector(wibble)] should_not be_truthy;
    });

    it(@"should not affect other instances of the same class", ^{
        [[incrementer class] conformsToProtocol:@protocol(CedarDouble)] should be_truthy;

        id other_incrementer = [[[SimpleIncrementer alloc] init] autorelease];
        [[other_incrementer class] conformsToProtocol:@protocol(CedarDouble)] should_not be_truthy;
    });

    it(@"should record messages sent to the object", ^{
        incrementer should_not have_received("increment");
        [incrementer increment];
        incrementer should have_received("increment");
    });

    xit(@"should record messages sent by the object to itself", ^{
        [incrementer incrementBy:7];
        incrementer should have_received("setValue:");
    });

    it(@"should return the description of the spied-upon object", ^{
        incrementer.description should contain(@"SimpleIncrementer");
    });

    it(@"should only spy on a given object once" , ^{
        [incrementer increment];
        spy_on(incrementer);
        incrementer should have_received("increment");
    });
});

SPEC_END
