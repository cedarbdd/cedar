#import <Cedar/SpecHelper.h>
#import "SimpleIncrementer.h"
#import "ObjectWithForwardingTarget.h"
#import "ArgumentReleaser.h"
#import "ObjectWithProperty.h"
#import "SimpleKeyValueObserver.h"
#import "ArgumentReleaser.h"
#import <objc/runtime.h>

extern "C" {
#import "ExpectFailureWithMessage.h"
#import "ObjectWithCollections.h"
#import "CedarObservedObject.h"
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

    describe(@"method spying", ^{
        context(@"with an argument that is released by the observed method", ^{
            it(@"should retain the argument", ^{
                ArgumentReleaser *releaser = [[[ArgumentReleaser alloc] init] autorelease];
                spy_on(releaser);

                ArgumentReleaser *citizen = [[ArgumentReleaser alloc] init];
                [releaser releaseArgument:citizen];

                citizen should_not be_nil;
                releaser should have_received(@selector(releaseArgument:)).with(citizen);
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
        SEL wibbleSelector = NSSelectorFromString(@"wibble");
        [incrementer respondsToSelector:@selector(increment)] should be_truthy;
        [incrementer respondsToSelector:wibbleSelector] should_not be_truthy;
    });

    it(@"should not affect other instances of the same class", ^{
        [object_getClass(incrementer) conformsToProtocol:@protocol(CedarDouble)] should be_truthy;

        id other_incrementer = [[[SimpleIncrementer alloc] init] autorelease];
        [object_getClass(other_incrementer) conformsToProtocol:@protocol(CedarDouble)] should_not be_truthy;
    });

    it(@"should record messages sent to the object", ^{
        incrementer should_not have_received("increment");
        [incrementer increment];
        incrementer should have_received("increment");
    });

    describe(@"class identity", ^{
        it(@"-isKindOfClass: should work as expected", ^{
            [incrementer isKindOfClass:[SimpleIncrementer class]] should be_truthy;
            [incrementer isKindOfClass:[NSObject class]] should be_truthy;
        });

        it(@"-class should return original class", ^{
            [incrementer class] should equal([SimpleIncrementer class]);
        });
    });

    it(@"should record messages sent by the object to itself", ^{
        [incrementer incrementBy:7];
        incrementer should have_received("setValue:");
    });

    it(@"should raise a meaningful error when sent an unrecognized message", ^{
        NSString *expectedReason = [NSString stringWithFormat:@"-[SimpleIncrementer rangeOfComposedCharacterSequenceAtIndex:]: unrecognized selector sent to spy %p", incrementer];
        ^{
            [(id)incrementer rangeOfComposedCharacterSequenceAtIndex:0];
        } should raise_exception.with_reason(expectedReason);
    });

    it(@"should return the description of the spied-upon object", ^{
        incrementer.description should contain(@"SimpleIncrementer");
    });

    it(@"should only spy on a given object once" , ^{
        [incrementer increment];
        spy_on(incrementer);
        incrementer should have_received("increment");
    });

    describe(@"spying on an object with a forwarding target", ^{
        __block ObjectWithForwardingTarget *forwardingObject;
        beforeEach(^{
            forwardingObject = [[[ObjectWithForwardingTarget alloc] initWithNumberOfThings:42] autorelease];
            spy_on(forwardingObject);
        });

        it(@"should not break message forwarding", ^{
            forwardingObject.count should equal(42);
        });

        it(@"should allow stubbing of publicly visible methods, even if forwarded in actual implementation", ^{
            forwardingObject stub_method("count").and_return((NSUInteger)666);

            forwardingObject.count should equal(666);
        });

        it(@"should raise a descriptive exception when a method signature couldn't be resolved", ^{
            ^{
                forwardingObject stub_method("unforwardedUnimplementedMethod");
            } should raise_exception.with_reason([NSString stringWithFormat:@"Attempting to stub method <unforwardedUnimplementedMethod>, which double <%@> does not respond to", [forwardingObject description]]);
        });
    });

    describe(@"spying on NSTimer (bridged object)", ^{
        __block NSTimer *timer;

        beforeEach(^{
            timer = [NSTimer timerWithTimeInterval:1 target:nil selector:nil userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            spy_on(timer);
        });

        it(@"should not stack overflow", ^{
            __block BOOL called = NO;

            dispatch_async(dispatch_get_main_queue(), ^{
                // calling this seems to trigger _cffireTime if it's not a
                // certain internal class, which then calls fireDate
                // if its class another internal timer class. This
                // cycle repeats forever unless the spy restores to
                // its original class.
                [timer fireDate] should_not be_nil;
                called = YES;
            });

            [[NSRunLoop currentRunLoop] addTimer:[NSTimer timerWithTimeInterval:0.1 invocation:nil repeats:NO] forMode:NSDefaultRunLoopMode];
            NSDate *futureDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
            [[NSRunLoop currentRunLoop] runUntilDate:futureDate];

            timer should have_received(@selector(fireDate));
        });

        afterEach(^{
            [timer invalidate];
        });
    });

    describe(@"spying on objects under KVO", ^{
        __block id observedObject;
        __block NSString *keyPath;
        __block SimpleKeyValueObserver *observer;

        void (^itShouldPlayNiceWithKVO)(void) = ^{
            it(@"should not raise exception when adding or removing an observer", ^{
                ^{ [observedObject addObserver:observer forKeyPath:keyPath options:0 context:NULL];
                    [observedObject removeObserver:observer forKeyPath:keyPath context:NULL]; }
                should_not raise_exception;
            });

            it(@"should not raise exception when adding or removing an observer", ^{
                ^{ [observedObject addObserver:observer forKeyPath:keyPath options:0 context:NULL];
                    [observedObject removeObserver:observer forKeyPath:keyPath context:NULL]; }
                should_not raise_exception;
            });

            it(@"should correctly record adding and removing an observer", ^{
                observedObject should_not have_received("addObserver:forKeyPath:options:context:");
                observedObject should_not have_received("removeObserver:forKeyPath:context:");

                [observedObject addObserver:observer forKeyPath:keyPath options:0 context:NULL];
                observedObject should have_received("addObserver:forKeyPath:options:context:");

                [observedObject removeObserver:observer forKeyPath:keyPath context:NULL];
                observedObject should have_received("removeObserver:forKeyPath:context:");
            });

            it(@"should record shorthand method for removing an observer", ^{
                observedObject should_not have_received("removeObserver:forKeyPath:");
                [observedObject addObserver:observer forKeyPath:keyPath options:0 context:NULL];

                [observedObject removeObserver:observer forKeyPath:keyPath];
                observedObject should have_received("removeObserver:forKeyPath:");
            });

            it(@"should not prevent existing observers from recording observations after they are spied upon", ^{
                [observedObject addObserver:observer forKeyPath:keyPath options:0 context:NULL];
                spy_on(observer);

                [observedObject mutateObservedProperty];
                observer should have_received("observeValueForKeyPath:ofObject:change:context:");

                [observedObject removeObserver:observer forKeyPath:keyPath];
            });

            it(@"should correctly notify other non-spy observers when an existing observer is spied", ^{
                SimpleKeyValueObserver *neutralObserver = [[[SimpleKeyValueObserver alloc] init] autorelease];
                [observedObject addObserver:neutralObserver forKeyPath:keyPath options:0 context:NULL];
                [observedObject addObserver:observer forKeyPath:keyPath options:0 context:NULL];
                spy_on(observer);

                [observedObject mutateObservedProperty];
                neutralObserver.lastObservedKeyPath should equal(keyPath);

                [observedObject removeObserver:neutralObserver forKeyPath:keyPath];
                [observedObject removeObserver:observer forKeyPath:keyPath];
            });

            it(@"should not notify observers method after being removed", ^{
                [observedObject addObserver:observer forKeyPath:keyPath options:0 context:NULL];
                [observedObject removeObserver:observer forKeyPath:keyPath];
                spy_on(observer);

                [observedObject mutateObservedProperty];
                observer should_not have_received("observeValueForKeyPath:ofObject:change:context:");
            });
        };

        context(@"with a KVO on a simple property", ^{
            beforeEach(^{
                keyPath = @"floatProperty";
                observedObject = [[[ObjectWithProperty alloc] init] autorelease];
                spy_on(observedObject);
                observer = [[[SimpleKeyValueObserver alloc] init] autorelease];
            });

            itShouldPlayNiceWithKVO();
        });

        context(@"with KVO on an array property", ^{
            beforeEach(^{
                keyPath = @"array";
                observedObject = [[[ObjectWithCollections alloc] init] autorelease];
                spy_on(observedObject);
                observer = [[[SimpleKeyValueObserver alloc] init] autorelease];
            });

            itShouldPlayNiceWithKVO();
        });

        context(@"with KVO on a set property", ^{
            beforeEach(^{
                keyPath = @"set";
                observedObject = [[[ObjectWithCollections alloc] init] autorelease];
                spy_on(observedObject);
                observer = [[[SimpleKeyValueObserver alloc] init] autorelease];
            });

            itShouldPlayNiceWithKVO();
        });

        context(@"with KVO on an ordered set property", ^{
            beforeEach(^{
                keyPath = @"orderedSet";
                observedObject = [[[ObjectWithCollections alloc] init] autorelease];
                spy_on(observedObject);
                observer = [[[SimpleKeyValueObserver alloc] init] autorelease];
            });

            itShouldPlayNiceWithKVO();
        });

        context(@"with a KVO on a simple manual property", ^{
            beforeEach(^{
                keyPath = @"manualFloatProperty";
                observedObject = [[[ObjectWithProperty alloc] init] autorelease];
                spy_on(observedObject);
                observer = [[[SimpleKeyValueObserver alloc] init] autorelease];
            });

            itShouldPlayNiceWithKVO();
        });

        context(@"with KVO on a manual array", ^{
            beforeEach(^{
                keyPath = @"manualArray";
                observedObject = [[[ObjectWithCollections alloc] init] autorelease];
                spy_on(observedObject);
                observer = [[[SimpleKeyValueObserver alloc] init] autorelease];
            });

            itShouldPlayNiceWithKVO();
        });

        context(@"with KVO on a manual set", ^{
            beforeEach(^{
                keyPath = @"manualSet";
                observedObject = [[[ObjectWithCollections alloc] init] autorelease];
                spy_on(observedObject);
                observer = [[[SimpleKeyValueObserver alloc] init] autorelease];
            });

            itShouldPlayNiceWithKVO();
        });
    });
});

describe(@"stop_spying_on", ^{
    it(@"should blow up in an obvious manner when spying on nil", ^{
        ^{ stop_spying_on(nil); } should raise_exception.with_reason(@"Cannot stop spying on nil");
    });

    it(@"should fail gracefully for an object that is not being spied upon", ^{
        NSObject *object = [[NSObject new] autorelease];
        ^{ stop_spying_on(object); } should_not raise_exception;
    });
});

SPEC_END
