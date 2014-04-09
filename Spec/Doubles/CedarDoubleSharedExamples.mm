#import <Cedar/SpecHelper.h>
#import "SimpleIncrementer.h"
#import "StubbedMethod.h"
#import "CedarDoubleImpl.h"
#import "FooSuperclass.h"

SHARED_EXAMPLE_GROUPS_BEGIN(CedarDoubleSharedExamples)

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;
using namespace Cedar::Doubles::Arguments;

sharedExamplesFor(@"a Cedar double", ^(NSDictionary *sharedContext) {
    __block id<CedarDouble, SimpleIncrementer> myDouble;

    beforeEach(^{
        myDouble = [sharedContext objectForKey:@"double"];
    });

    describe(@"sent_messages", ^{
        beforeEach(^{
            myDouble stub_method("value");
            [myDouble value];
        });

        it(@"should have one recording per message sent", ^{
            [[myDouble sent_messages] count] should equal(1);
        });
    });

    context(@"where the expected type is a char * and a char * is passed", ^{
        it(@"should just work", ^{
            ^{ myDouble stub_method("methodWithCString:").with("hello"); } should_not raise_exception;
        });
    });

    describe(@"reset_sent_messages", ^{
        beforeEach(^{
            myDouble stub_method("value");
            [myDouble value];
            myDouble should have_received("value");

            [myDouble reset_sent_messages];
        });

        it(@"should remove any previously recorded invocations", ^{
            myDouble should_not have_received("value");
        });
    });

    context(@"when recording an invocation", ^{
        it(@"should release the invocations retaining the double in afterEach", ^{
            static NSInteger numInvocations = 2;
            myDouble stub_method("value");

            NSUInteger doubleRetainCount = myDouble.retainCount;

            // spies are allowed to increment the retain count of the double by 1
            // but should hand the retain over to the autorelease pool
            @autoreleasepool {
                for (NSInteger invocation = 0; invocation < numInvocations; ++invocation) {
                    [myDouble value];
                }
            }

            myDouble.retainCount should equal(doubleRetainCount + numInvocations);

            [CedarDoubleImpl afterEach];

            myDouble.retainCount should equal(doubleRetainCount);
        });

        it(@"should exchange any block arguments with copies that can later be invoked", ^{
            __block BOOL blockWasCalled = NO;
            void *blockVariableLocationOnStack = &blockWasCalled;

            myDouble stub_method("methodWithBlock:");

            ^{
                void(^originalBlock)() = ^{
                    blockWasCalled = YES;
                };
                [myDouble methodWithBlock:originalBlock];
            }();

            NSInvocation *invocationWithBlock = [[myDouble sent_messages] lastObject];
            void(^retrievedBlock)() = nil;

            [invocationWithBlock getArgument:&retrievedBlock atIndex:2];

            //Blocks don't change memory address when copied but we can detect copying
            //by observing when it's enclosed block variables are moved to the heap.
            //See: http://www.cocoawithlove.com/2009/10/how-blocks-are-implemented-and.html
            (void *)&blockWasCalled should_not equal(blockVariableLocationOnStack);
            retrievedBlock();
            blockWasCalled should be_truthy;
        });

        it(@"should exchange any c-string arguments with copies that can later be accessed", ^{
            char *string = (char *)malloc(6);
            strcpy(string, "hello");

            myDouble stub_method("methodWithCString:");

            [myDouble methodWithCString:string];
            strcpy(string, "byeby");

            NSInvocation *invocation = [[myDouble sent_messages] lastObject];
            char *argument = NULL;
            [invocation getArgument:&argument atIndex:2];

            argument == string should_not be_truthy;
            strcmp("hello", argument) should equal(0);

            free(string);
        });
    });

    describe(@"-stub_method", ^{
        context(@"with a non-double", ^{
            it(@"should raise an exception", ^{
                NSObject *non_double = [[[NSObject alloc] init] autorelease];
                ^{ non_double stub_method("description"); } should raise_exception.with_reason([NSString stringWithFormat:@"%@ is not a double", non_double]);
            });
        });

        context(@"with a method name that the stub does not respond to", ^{
            it(@"should raise an exception", ^{
                ^{ myDouble stub_method("wibble_wobble"); } should raise_exception.with_reason([NSString stringWithFormat:@"Attempting to stub method <wibble_wobble>, which double <%@> does not respond to", myDouble]);
            });
        });

        context(@"with a method with no arguments", ^{
            context(@"when stubbed twice", ^{
                it(@"should raise an exception", ^{
                    myDouble stub_method("value");
                    ^{ myDouble stub_method("value"); } should raise_exception.with_reason(@"The method <value> is already stubbed with arguments ()");
                });
            });

            context(@"with no return value", ^{
                beforeEach(^{
                    myDouble stub_method("value");
                });

                it(@"should record the invocation", ^{
                    [myDouble value];
                    myDouble should have_received("value");
                });

                it(@"should return zero", ^{
                    myDouble.value should equal(0);
                });
            });

            context(@"with a return value of the correct type", ^{
                size_t someArgument = 1;

                beforeEach(^{
                    myDouble stub_method("value").and_return(someArgument);
                });

                it(@"should return the specified return value", ^{
                    myDouble.value should equal(someArgument);
                });
            });

            context(@"with a return value of a type with the wrong binary size", ^{
                int someArgument = 1;

                it(@"should raise an exception", ^{
                    ^{ myDouble stub_method("value").and_return(someArgument); } should raise_exception;
                });
            });

            context(@"with a return value of an inappropriate type", ^{
                it(@"should raise an exception", ^{
                    ^{ myDouble stub_method("value").and_return(@"foo"); } should raise_exception;
                });
            });
        });

        context(@"when the stub is instructed to raise an exception (and_raise)", ^{
            context(@"with no parameter", ^{
                beforeEach(^{
                    myDouble stub_method("increment").and_raise_exception();
                });

                it(@"should raise a generic exception", ^{
                    ^{ [myDouble increment]; } should raise_exception([NSException class]);
                });
            });

            context(@"with a specified exception", ^{
                id someException = @"that's some pig (exception)";

                beforeEach(^{
                    myDouble stub_method("increment").and_raise_exception(someException);
                });

                it(@"should raise that exception instance", ^{
                    ^{ [myDouble increment]; } should raise_exception(someException);
                });
            });
        });

        context(@"with a replacement implementation receiving the method's arguments (and_do_block)", ^{
            context(@"with a valid block that only has a return value", ^{
                __block BOOL implementation_block_called;
                size_t return_value = 123;

                beforeEach(^{
                    implementation_block_called = NO;

                    myDouble stub_method("value").and_do_block(^size_t {
                        implementation_block_called = YES;
                        return return_value;
                    });
                });

                it(@"should invoke the block", ^{
                    [myDouble value];
                    implementation_block_called should be_truthy;
                });

                it(@"should return the value returned from the block", ^{
                    [myDouble value] should equal(return_value);
                });

                context(@"when combined with an explicit return value", ^{
                    it(@"should raise an exception", ^{
                        ^{
                            myDouble stub_method("value").and_do_block(^size_t{ return 0; }).and_return(2);
                        } should raise_exception.with_reason(@"Multiple return values specified for <value>");
                    });
                });

                context(@"when added after an explicit return value", ^{
                    it(@"should raise an exception", ^{
                        ^{
                            myDouble stub_method("value").and_return(2).and_do_block(^size_t{ return 0; });
                        } should raise_exception.with_reason(@"Multiple return values specified for <value>");
                    });
                });

                context(@"when combined with an invocation block", ^{
                    it(@"should raise an exception", ^{
                        ^{
                            myDouble stub_method("value").and_do_block(^size_t{ return 0; }).and_do(^(NSInvocation *invocation) {});
                        } should raise_exception.with_reason(@"Multiple blocks specified for <value>");
                    });
                });

                context(@"when added after an invocation block", ^{
                    it(@"should raise an exception", ^{
                        ^{
                            myDouble stub_method("value").and_do(^(NSInvocation *invocation) {}).and_do_block(^size_t{ return 0; });
                        } should raise_exception.with_reason(@"Multiple blocks specified for <value>");
                    });
                });
            });

            context(@"with a valid block that has primitive integer arguments", ^{
                size_t sent_argument = 2;
                __block size_t received_argument;

                beforeEach(^{
                    received_argument = 0;

                    myDouble stub_method("incrementBy:").and_do_block(^(size_t arg) {
                        received_argument = arg;
                    });
                    [myDouble incrementBy:sent_argument];
                });

                it(@"should be passed the correct arguments", ^{
                    received_argument should equal(sent_argument);
                });
            });

            context(@"with a valid block that has primitive floating point arguments", ^{
                double sent_argument = 9876.54321;
                __block double received_argument1, received_argument2;
                double return_value = 192837.465;

                beforeEach(^{
                    received_argument1 = received_argument2 = 0;

                    myDouble stub_method("methodWithDouble1:andDouble2:").and_do_block(^double(double double1, double double2) {
                        received_argument1 = double1;
                        received_argument2 = double2;
                        return return_value;
                    });
                    [myDouble methodWithDouble1:sent_argument andDouble2:sent_argument];
                });

                it(@"should be passed the correct arguments", ^{
                    received_argument1 should equal(sent_argument);
                    received_argument2 should equal(sent_argument);
                });

                it(@"should return the value returned from the block", ^{
                    [myDouble methodWithDouble1:0 andDouble2:0] should equal(return_value);
                });
            });

            context(@"with a valid block that uses large structs", ^{
                LargeIncrementerStruct sent_argument = { 1234567, 98765432, 42, SIZE_T_MAX };
                __block LargeIncrementerStruct received_argument;
                LargeIncrementerStruct return_value = { 123, 456, 789, SIZE_T_MAX };

                beforeEach(^{
                    received_argument = {};

                    myDouble stub_method("methodWithLargeStruct1:andLargeStruct2:").and_do_block(^LargeIncrementerStruct(LargeIncrementerStruct struct1, LargeIncrementerStruct struct2) {
                        received_argument = struct2;
                        return return_value;
                    });
                    [myDouble methodWithLargeStruct1:sent_argument andLargeStruct2:sent_argument];
                });

                it(@"should be passed the correct struct arguments", ^{
                    memcmp(&received_argument, &sent_argument, sizeof(sent_argument)) should equal(0);
                });

                it(@"should return the struct value returned from the block", ^{
                    LargeIncrementerStruct returned_value = [myDouble methodWithLargeStruct1:sent_argument andLargeStruct2:sent_argument];
                    memcmp(&return_value, &returned_value, sizeof(return_value)) should equal(0);
                });
            });

            context(@"with a valid block that uses objects", ^{
                NSNumber *sent_argument = @(M_PI);
                __block NSNumber *received_argument;
                NSNumber *return_value = @(42);

                beforeEach(^{
                    received_argument = nil;

                    myDouble stub_method("methodWithNumber1:andNumber2:").and_do_block(^NSNumber *(NSNumber *num1, NSNumber *num2) {
                        received_argument = num1;
                        return return_value;
                    });
                    [myDouble methodWithNumber1:sent_argument andNumber2:sent_argument];
                });

                it(@"should be passed the correct object arguments", ^{
                    received_argument should be_same_instance_as(sent_argument);
                });

                it(@"should return the object value returned from the block", ^{
                    [myDouble methodWithNumber1:@(1) andNumber2:@(2)] should be_same_instance_as(return_value);
                });
            });

            context(@"with a valid block that takes a complex block as a parameter", ^{
                ComplexIncrementerBlock sent_argument = ^LargeIncrementerStruct(NSNumber *, LargeIncrementerStruct, NSError *){ return (LargeIncrementerStruct){}; };
                __block ComplexIncrementerBlock received_argument;

                beforeEach(^{
                    received_argument = nil;

                    myDouble stub_method("methodWithNumber:complexBlock:").and_do_block(^(NSNumber *, ComplexIncrementerBlock block) {
                        received_argument = block;
                    });
                    [myDouble methodWithNumber:@(1) complexBlock:sent_argument];
                });

                it(@"should be passed the correct block argument", ^{
                    received_argument should equal(sent_argument);
                });
            });

            context(@"with something not a block", ^{
                it(@"should raise an exception", ^{
                    ^{ myDouble stub_method("value").and_do_block(@(2)); } should raise_exception.with_reason([NSString stringWithFormat:@"Attempted to stub and do a block that isn't a block for <value>"]);
                });
            });

            context(@"with a block that does not match the method's return type", ^{
                void (^invalidBlock)(void) = ^{};
                it(@"should raise an exception", ^{
                    ^{ myDouble stub_method("value").and_do_block(invalidBlock); } should raise_exception.with_reason([NSString stringWithFormat:@"Invalid return type '%s' instead of '%s' for <value>", @encode(void), @encode(size_t)]);
                });
            });

            context(@"with a block that has a different number of arguments than the method", ^{
                void (^invalidBlock)(void) = ^{};
                it(@"should raise an exception", ^{
                    ^{ myDouble stub_method("incrementBy:").and_do_block(invalidBlock); } should raise_exception.with_reason(@"Wrong number of parameters for <incrementBy:>; expected: 1; actual: 0 (not counting the special first parameter, `id self`)");
                });
            });

            context(@"with a block that has a different argument type than the method", ^{
                void (^invalidBlock)(float) = ^(float){};
                it(@"should raise an exception", ^{
                    ^{ myDouble stub_method("incrementBy:").and_do_block(invalidBlock); } should raise_exception.with_reason([NSString stringWithFormat:@"Found argument type '%s', expected '%s'; argument #1 for <incrementBy:>", @encode(float), @encode(size_t)]);
                });
            });
        });

        context(@"with a replacement implementation receiving an invocation (and_do)", ^{
            __block BOOL replacement_invocation_called;
            __block size_t sent_argument = 2, received_argument;
            __block size_t return_value;

            beforeEach(^{
                replacement_invocation_called = NO;
                return_value = 123;
                myDouble stub_method("incrementBy:").and_do(^(NSInvocation *invocation) {
                    replacement_invocation_called = YES;
                    [invocation getArgument:&received_argument atIndex:2];
                });
                myDouble stub_method("value").and_do(^(NSInvocation *invocation) {
                    [invocation setReturnValue:&return_value];
                });

                [myDouble incrementBy:sent_argument];
            });

            it(@"should invoke the block", ^{
                replacement_invocation_called should be_truthy;
            });

            it(@"should receive the correct arguments in the invocation", ^{
                received_argument should equal(sent_argument);
            });

            it(@"should return the value provided by the NSInvocation", ^{
                [myDouble value] should equal(return_value);
            });

            context(@"when combined with an explicit return value", ^{
                it(@"should raise an exception", ^{
                    ^{
                        myDouble stub_method("value").and_do(^(NSInvocation *invocation) {}).and_return(2);
                    } should raise_exception.with_reason(@"Multiple return values specified for <value>");
                });
            });

            context(@"when added after an explicit return value", ^{
                it(@"should raise an exception", ^{
                    ^{
                        myDouble stub_method("value").and_return(2).and_do(^(NSInvocation *invocation) {});
                    } should raise_exception.with_reason(@"Multiple return values specified for <value>");
                });
            });

            context(@"when combined with an implementation block", ^{
                it(@"should raise an exception", ^{
                    ^{
                        myDouble stub_method("value").and_do(^(NSInvocation *invocation) {}).and_do_block(^size_t{ return 0; });
                    } should raise_exception.with_reason(@"Multiple blocks specified for <value>");
                });
            });

            context(@"when added after an implementation block", ^{
                it(@"should raise an exception", ^{
                    ^{
                        myDouble stub_method("value").and_do_block(^size_t{ return 0; }).and_do(^(NSInvocation *invocation) {});
                    } should raise_exception.with_reason(@"Multiple blocks specified for <value>");
                });
            });
        });

        describe(@"argument expectations", ^{
            describe(@"when stubbing the same method multiple times", ^{
                context(@"with distinctly different arguments", ^{
                    context(@"primitive arguments", ^{
                        __block BOOL firstStubWasCalled, secondStubWasCalled;
                        beforeEach(^{
                            firstStubWasCalled = secondStubWasCalled = NO;
                            myDouble stub_method("incrementByInteger:").with(1).and_do(^(NSInvocation *) {
                                firstStubWasCalled = YES;
                            });
                            myDouble stub_method("incrementByInteger:").with(3).and_do(^(NSInvocation *) {
                                secondStubWasCalled = YES;
                            });
                        });

                        it(@"should perform the stub action associated with those arguments when invoked with those arguments", ^{
                            [myDouble incrementByInteger:3];
                            secondStubWasCalled should be_truthy;
                            firstStubWasCalled should_not be_truthy;
                        });
                    });

                    context(@"object arguments", ^{
                        NSNumber *arg1 = @1;
                        NSNumber *arg2 = @2;
                        NSNumber *returnValue1 = @3;
                        NSNumber *arg3 = @88;
                        NSNumber *returnValue2 = @42;
                        __block void(^stubMethodAgainWithDifferentArugmentsBlock)();

                        beforeEach(^{
                            myDouble stub_method("methodWithNumber1:andNumber2:").with(arg1, arg2).and_return(returnValue1);
                            stubMethodAgainWithDifferentArugmentsBlock = [^{ myDouble stub_method("methodWithNumber1:andNumber2:").with(arg1, arg3).and_return(returnValue2); } copy];
                        });

                        afterEach(^{
                            [stubMethodAgainWithDifferentArugmentsBlock release];
                        });

                        it(@"should not raise an exception", ^{
                            stubMethodAgainWithDifferentArugmentsBlock should_not raise_exception();
                        });

                        context(@"when invoked", ^{
                            beforeEach(^{
                                stubMethodAgainWithDifferentArugmentsBlock();
                            });

                            it(@"should return the value associated with the corresponding arguments", ^{
                                [myDouble methodWithNumber1:arg1 andNumber2:arg2] should equal(returnValue1);
                                [myDouble methodWithNumber1:arg1 andNumber2:arg3] should equal(returnValue2);
                            });
                        });
                    });
                });

                context(@"with the same arguments", ^{
                    context(@"primitive arguments", ^{
                        NSInteger arg1 = 1;
                        it(@"should raise an exception", ^{
                            myDouble stub_method("incrementByInteger:").with(arg1);
                            ^{ myDouble stub_method("incrementByInteger:").with(arg1); } should raise_exception().with_reason(@"The method <incrementByInteger:> is already stubbed with arguments (<1>)");
                        });
                    });

                    context(@"object arguments", ^{
                        NSNumber *arg1 = @1;
                        NSNumber *arg2 = @2;
                        NSNumber *returnValue1 = @3;

                        it(@"should raise an exception", ^{
                            myDouble stub_method("methodWithNumber1:andNumber2:").with(arg1, arg2).and_return(returnValue1);
                            ^{ myDouble stub_method("methodWithNumber1:andNumber2:").with(arg1, arg2).and_return(@91); } should raise_exception().with_reason(@"The method <methodWithNumber1:andNumber2:> is already stubbed with arguments (<1><2>)");
                        });
                    });
                });

                context(@"with no arguments, then the anything argument", ^{
                    it(@"should raise an exception", ^{
                        myDouble stub_method("incrementByInteger:");
                        ^{ myDouble stub_method("incrementByInteger:").with(Arguments::anything); } should raise_exception;
                    });
                });

                context(@"with the anything argument, then with no arguments", ^{
                    it(@"should raise an exception", ^{
                        myDouble stub_method("incrementByInteger:").with(Arguments::anything);
                        ^{ myDouble stub_method("incrementByInteger:"); } should raise_exception;
                    });
                });

                context(@"with the anything argument in different positions", ^{
                    beforeEach(^{
                        myDouble stub_method("methodWithNumber1:andNumber2:").with(@1, Arguments::anything).and_return(@1);
                        myDouble stub_method("methodWithNumber1:andNumber2:").with(Arguments::anything, @2).and_return(@2);
                    });

                    it(@"should choose the correct stub to invoke based on the specific arguments", ^{
                        [myDouble methodWithNumber1:@1 andNumber2:@3] should equal(@1);
                        [myDouble methodWithNumber1:@3 andNumber2:@2] should equal(@2);
                    });

                    it(@"should choose the most recent stub if more than one stub matches ", ^{
                        [myDouble methodWithNumber1:@1 andNumber2:@2] should equal(@2);
                    });
                });

                context(@"with Arguments::any()", ^{
                    __block void(^stubMethodAgainWithNoArgumentsBlock)();
                    __block void(^stubMethodAgainWithAnyArgumentBlock)();
                    __block FooSuperclass *specificInstance;
                    __block BarSubclass *specificBarInstance;

                    beforeEach(^{
                        specificInstance = [[[FooSuperclass alloc] init] autorelease];
                        specificBarInstance = [[[BarSubclass alloc] init] autorelease];
                        myDouble stub_method("methodWithFooSuperclass:").with(specificInstance).and_return(@"foo");
                        myDouble stub_method("methodWithFooSuperclass:").with(specificBarInstance).and_return(@"bar_specific");

                        stubMethodAgainWithNoArgumentsBlock = [^{ myDouble stub_method("methodWithFooSuperclass:").and_return(@"quux"); } copy];
                        stubMethodAgainWithAnyArgumentBlock = [^{ myDouble stub_method("methodWithFooSuperclass:").with(Arguments::any([BarSubclass class])).and_return(@"bar"); } copy];
                    });

                    afterEach(^{
                        [stubMethodAgainWithNoArgumentsBlock release];
                        [stubMethodAgainWithAnyArgumentBlock release];
                    });

                    it(@"should not raise an exception", ^{
                        stubMethodAgainWithNoArgumentsBlock should_not raise_exception;
                        stubMethodAgainWithAnyArgumentBlock should_not raise_exception;
                    });

                    context(@"when invoked", ^{
                        beforeEach(^{
                            stubMethodAgainWithNoArgumentsBlock();
                            stubMethodAgainWithAnyArgumentBlock();
                        });

                        it(@"should match the stub for specific instances", ^{
                            [myDouble methodWithFooSuperclass:specificInstance] should equal(@"foo");
                            [myDouble methodWithFooSuperclass:specificBarInstance] should equal(@"bar_specific");
                        });

                        it(@"should match the stub for Arguments::any()", ^{
                            [myDouble methodWithFooSuperclass:[[[BarSubclass alloc] init] autorelease]] should equal(@"bar");
                            [myDouble methodWithFooSuperclass:[[[QuuxSubclass alloc] init] autorelease]] should equal(@"quux");
                        });

                        it(@"should match the unqualified stub", ^{
                            [myDouble methodWithFooSuperclass:nil] should equal(@"quux");
                        });
                    });
                });
            });

            context(@"when specified with .with(varargs)", ^{
                NSNumber *arg1 = @1;;
                NSNumber *arg2 = @2;
                NSNumber *arg3 = @3;
                NSNumber *returnValue = @99;

                context(@"with the incorrect number of arguments", ^{
                    it(@"should raise an exception when invoked with too few arguments", ^{
                        NSString *reason = @"Wrong number of expected parameters for <methodWithNumber1:andNumber2:>; expected: 1, actual: 2";
                        ^{ myDouble stub_method("methodWithNumber1:andNumber2:").with(arg1).and_return(returnValue); } should raise_exception.with_reason(reason);
                    });

                    it(@"should raise an exception when invoked with too many arguments", ^{
                        NSString *reason = @"Wrong number of expected parameters for <methodWithNumber1:andNumber2:>; expected: 3, actual: 2";
                        ^{ myDouble stub_method("methodWithNumber1:andNumber2:").with(arg1, arg2, arg3).and_return(returnValue); } should raise_exception.with_reason(reason);
                    });
                });

                context(@"with the correct number of arguments", ^{
                    context(@"of the correct types", ^{
                        beforeEach(^{
                            myDouble stub_method("methodWithNumber1:andNumber2:").with(arg1, arg2).and_return(returnValue);
                        });

                        context(@"when invoked with a parameters of the expected value", ^{
                            it(@"should return the returnValue", ^{
                                [myDouble methodWithNumber1:arg1 andNumber2:arg2] should equal(returnValue);
                            });
                        });
                    });

                    context(@"of incorrect types", ^{
                        NSString *reason = @"Attempt to compare expected argument <10> with actual argument type @; argument #2 for <methodWithNumber1:andNumber2:>";
                        it(@"should raise an exception", ^{
                            int invalidInt = 10;
                            ^{ myDouble stub_method("methodWithNumber1:andNumber2:").with(arg1, invalidInt); } should raise_exception.with_reason(reason);
                        });
                    });
                });
            });

            context(@"when specified with .with().and_with()", ^{
                context(@"with too few", ^{
                    size_t expectedIncrementValue = 1;
                    NSString *reason = [NSString stringWithFormat:@"Wrong number of expected parameters for <incrementByABit:andABitMore:>; expected: 1, actual: 2"];

                    it(@"should raise an exception", ^{
                        ^{ myDouble stub_method("incrementByABit:andABitMore:").with(expectedIncrementValue); } should raise_exception.with_reason(reason);
                    });
                });

                context(@"with too many", ^{
                    NSString *reason = [NSString stringWithFormat:@"Wrong number of expected parameters for <value>; expected: 1, actual: 0"];

                    it(@"should raise an exception", ^{
                        ^{ myDouble stub_method("value").with(@"foo"); } should raise_exception.with_reason(reason);
                    });
                });

                context(@"with the correct number", ^{
                    NSNumber *expectedBitMoreValue = @10;
                    context(@"of the correct types", ^{
                        size_t expectedIncrementValue = 1;

                        beforeEach(^{
                            myDouble stub_method("incrementByABit:andABitMore:").with(expectedIncrementValue).and_with(expectedBitMoreValue);
                        });

                        context(@"when invoked with a parameter of the expected value", ^{
                            it(@"should not raise an exception", ^{
                                [myDouble incrementByABit:expectedIncrementValue andABitMore:expectedBitMoreValue];
                            });
                        });
                    });

                    context(@"of incorrect types", ^{
                        context(@"where the incorrect type is an object", ^{
                            it(@"should raise an exception", ^{
                                NSString *incorrectType = @"your mom";
                                NSString *reason = [NSString stringWithFormat:@"Attempt to compare expected argument <%@> with actual argument type %s; argument #1 for <incrementByABit:andABitMore:>", @"your mom", @encode(size_t)];
                                ^{ myDouble stub_method("incrementByABit:andABitMore:").with(incorrectType).and_with(expectedBitMoreValue); } should raise_exception.with_reason(reason);
                            });
                        });

                        context(@"where the incorrect type is a char *", ^{
                            it(@"should raise an exception", ^{
                                NSString *reason = [NSString stringWithFormat:@"Attempt to compare expected argument <cstring(%s)> with actual argument type %s; argument #1 for <incrementByABit:andABitMore:>", "your mom", @encode(size_t)];
                                ^{ myDouble stub_method("incrementByABit:andABitMore:").with((char *)"your mom").and_with(expectedBitMoreValue); } should raise_exception.with_reason(reason);
                            });
                        });

                        context(@"where the incorrect type is a non-object, non-cstring pointer", ^{
                            it(@"should raise an exception", ^{
                                int anInt = 1;
                                int *ptr = &anInt;
                                NSString *reason = [NSString stringWithFormat:@"Attempt to compare expected argument <%p> with actual argument type %s; argument #1 for <incrementByABit:andABitMore:>", ptr, @encode(size_t)];
                                ^{ myDouble stub_method("incrementByABit:andABitMore:").with(ptr).and_with(expectedBitMoreValue); } should raise_exception.with_reason(reason);
                            });
                        });
                    });
                });

                context(@"with a specific value", ^{
                    size_t expectedValue = 1;

                    beforeEach(^{
                        myDouble stub_method("incrementBy:").with(expectedValue);
                    });

                    context(@"when invoked with an argument of the expected value", ^{
                        it(@"should record the invocation", ^{
                            [myDouble incrementBy:expectedValue];
                            myDouble should have_received("incrementBy:").with(expectedValue);
                        });
                    });
                });

                context(@"with nil", ^{
                    __block BOOL stubbedBehaviorWasInvoked;
                    beforeEach(^{
                        stubbedBehaviorWasInvoked = NO;
                        myDouble stub_method("incrementByNumber:").with(nil).and_do(^(NSInvocation *) {
                            stubbedBehaviorWasInvoked = YES;
                        });
                    });

                    context(@"when invoked with a nil argument", ^{
                        beforeEach(^{
                            [myDouble incrementByNumber:nil];
                        });

                        it(@"should record the invocation", ^{
                            myDouble should have_received("incrementByNumber:").with(nil);
                        });

                        it(@"should invoke the stubbed behavior", ^{
                            stubbedBehaviorWasInvoked should be_truthy;
                        });
                    });
                });

                context(@"with an argument specified as anything", ^{
                    NSNumber *arg1 = @3;
                    NSNumber *arg2 = @123;
                    NSNumber *returnValueWithAnythingArg = @99;
                    NSNumber *returnValueWithExplicitArgs = @100;

                    context(@"and the 'anything' method is stubbed first", ^{
                        beforeEach(^{
                            myDouble stub_method("methodWithNumber1:andNumber2:").with(anything, arg2).and_return(returnValueWithAnythingArg);
                            myDouble stub_method("methodWithNumber1:andNumber2:").with(arg1, arg2).and_return(returnValueWithExplicitArgs);
                        });

                        it(@"should allow any value for the 'anything' argument", ^{
                            [myDouble methodWithNumber1:@8 andNumber2:arg2] should equal(returnValueWithAnythingArg);
                            [myDouble methodWithNumber1:@90210 andNumber2:arg2] should equal(returnValueWithAnythingArg);
                        });

                        context(@"and stubbing the method again with anything passed for the same parameter as in the stub", ^{
                            it(@"should raise an exception", ^{
                                ^{ myDouble stub_method("methodWithNumber1:andNumber2:").with(anything).and_with(arg2).and_return(returnValueWithAnythingArg); } should raise_exception.with_reason(@"The method <methodWithNumber1:andNumber2:> is already stubbed with arguments (<anything><123>)");
                            });
                        });

                        context(@"when two stubs exist", ^{
                            it(@"should invoke the more specific stub", ^{
                                [myDouble methodWithNumber1:arg1 andNumber2:arg2] should equal(returnValueWithExplicitArgs);
                            });
                        });
                    });

                    context(@"and the 'anything' method is stubbed second", ^{
                        beforeEach(^{
                            myDouble stub_method("methodWithNumber1:andNumber2:").with(arg1, arg2).and_return(returnValueWithExplicitArgs);
                            myDouble stub_method("methodWithNumber1:andNumber2:").with(anything, arg2).and_return(returnValueWithAnythingArg);
                        });

                        it(@"should allow any value for the 'anything' argument", ^{
                            [myDouble methodWithNumber1:@8 andNumber2:arg2] should equal(returnValueWithAnythingArg);
                            [myDouble methodWithNumber1:@90210 andNumber2:arg2] should equal(returnValueWithAnythingArg);
                        });

                        context(@"and stubbing the method again with anything passed for the same parameter as in the stub", ^{
                            it(@"should raise an exception", ^{
                                ^{ myDouble stub_method("methodWithNumber1:andNumber2:").with(anything).and_with(arg2).and_return(returnValueWithAnythingArg); } should raise_exception.with_reason(@"The method <methodWithNumber1:andNumber2:> is already stubbed with arguments (<anything><123>)");
                            });
                        });

                        context(@"when two stubs exist", ^{
                            it(@"should invoke the more specific stub", ^{
                                [myDouble methodWithNumber1:arg1 andNumber2:arg2] should equal(returnValueWithExplicitArgs);
                            });
                        });
                    });
                });

                context(@"with an argument specified as any instance of a specified class", ^{
                    NSNumber *arg = @123;
                    NSNumber *returnValue = @99;

                    beforeEach(^{
                        myDouble stub_method("methodWithNumber1:andNumber2:").with(any([NSDecimalNumber class]), arg).and_return(returnValue);
                    });

                    context(@"when invoked with the correct class", ^{
                        it(@"should return the expected value", ^{
                            [myDouble methodWithNumber1:[NSDecimalNumber decimalNumberWithDecimal:[@3.14159265359 decimalValue]] andNumber2:arg] should equal(returnValue);
                        });
                    });
                });
            });
        });

        describe(@"return values (and_return)", ^{
            context(@"with a value of the correct type", ^{
                size_t returnValue = 1729;

                beforeEach(^{
                    myDouble stub_method("value").and_return(returnValue);
                });

                it(@"should return the expected value", ^{
                    [myDouble value] should equal(returnValue);
                });
            });

            context(@"with a value of an incorrect type", ^{
                unsigned int invalidReturnValue = 3;

                it(@"should raise an exception", ^{
                    ^{ myDouble stub_method("value").and_return(invalidReturnValue); } should raise_exception.with_reason([NSString stringWithFormat:@"Invalid return value type '%s' instead of '%s' for <value>", @encode(unsigned int), @encode(size_t)]);
                });
            });
        });
    });
});

SHARED_EXAMPLE_GROUPS_END
