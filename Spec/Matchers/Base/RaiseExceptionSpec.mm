#if TARGET_OS_IPHONE
#import <Cedar/SpecHelper.h>
#else
#import <Cedar/SpecHelper.h>
#endif

extern "C" {
#import "ExpectFailureWithMessage.h"
}

@interface CustomException : NSException; @end
@implementation CustomException; @end

@interface SubclassException : CustomException; @end
@implementation SubclassException; @end

@interface AnotherSubclassException : CustomException; @end
@implementation AnotherSubclassException; @end

using namespace Cedar::Matchers;

SPEC_BEGIN(RaiseExceptionSpec)

describe(@"raise_exception matcher", ^{
    __block void (^block)();
    __block NSException *exception;

    context(@"with no exception class specified", ^{
        context(@"when the block throws an exception", ^{
            beforeEach(^{
                exception = [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Because" userInfo:nil];
                block = [[^{
                    [exception raise];
                } copy] autorelease];
            });

            context(@"when called with parentheses", ^{
                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        block should raise_exception;
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not raise an exception", block], ^{
                            block should_not raise_exception;
                        });
                    });
                });
            });

            context(@"when called without parentheses", ^{
                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        block should raise_exception;
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not raise an exception", block], ^{
                            block should_not raise_exception;
                        });
                    });
                });
            });
        });

        context(@"when the block does not throw an exception", ^{
            beforeEach(^{
                block = [[^{} copy] autorelease];
            });

            context(@"when called with parentheses", ^{
                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to raise an exception", block], ^{
                            block should raise_exception;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        block should_not raise_exception;
                    });
                });
            });

            context(@"when called without parentheses", ^{
                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to raise an exception", block], ^{
                            block should raise_exception;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        block should_not raise_exception;
                    });
                });
            });
        });
    });

    context(@"with an exception class specified", ^{
        Class expectedExceptionClass = [CustomException class];

        context(@"when the block throws an exception of that class", ^{
            beforeEach(^{
                exception = [expectedExceptionClass exceptionWithName:NSInternalInconsistencyException reason:@"Because" userInfo:nil];
                block = [[^{
                    [exception raise];
                } copy] autorelease];
            });

            describe(@"positive match", ^{
                it(@"should pass", ^{
                    block should raise_exception(expectedExceptionClass);
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not raise an exception of class <%@>", block, NSStringFromClass(expectedExceptionClass)], ^{
                        block should_not raise_exception(expectedExceptionClass);
                    });
                });
            });
        });

        context(@"when the block throws an exception of a sublass of the specified class", ^{
            beforeEach(^{
                exception = [SubclassException exceptionWithName:NSInternalInconsistencyException reason:@"Because" userInfo:nil];
                block = [[^{
                    [exception raise];
                } copy] autorelease];
            });

            context(@"when subclass exceptions are expected", ^{
                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        block should raise_exception(expectedExceptionClass).or_subclass();
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not raise an exception of class, or subclass of class, <%@>", block, NSStringFromClass([expectedExceptionClass class])], ^{
                            block should_not raise_exception(expectedExceptionClass).or_subclass();
                        });
                    });
                });
            });

            context(@"when subclass exceptions are not expected", ^{
                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to raise an exception of class <%@>", block, NSStringFromClass([expectedExceptionClass class])], ^{
                            block should raise_exception(expectedExceptionClass);
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        block should_not raise_exception(expectedExceptionClass);
                    });
                });
            });
        });

        context(@"when the block throws an exception of an unrelated class", ^{
            beforeEach(^{
                exception = [AnotherSubclassException exceptionWithName:NSInternalInconsistencyException reason:@"Because" userInfo:nil];
                block = [[^{
                    [exception raise];
                } copy] autorelease];
            });

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to raise an exception of class <%@>", block, NSStringFromClass([expectedExceptionClass class])], ^{
                        block should raise_exception(expectedExceptionClass);
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    block should_not raise_exception(expectedExceptionClass);
                });
            });
        });

        context(@"when the block does not throw an exception", ^{
            beforeEach(^{
                block = [[^{} copy] autorelease];
            });

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to raise an exception of class <%@>", block, NSStringFromClass([expectedExceptionClass class])], ^{
                        block should raise_exception(expectedExceptionClass);
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    block should_not raise_exception(expectedExceptionClass);
                });
            });
        });
    });

    context(@"with a reason specified", ^{
        NSString *reason = @"Because of something you did.";

        context(@"when the block throws an exception with the specified reason", ^{
            beforeEach(^{
                exception = [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
                block = [[^{
                    [exception raise];
                } copy] autorelease];
            });

            describe(@"positive match", ^{
                it(@"should pass", ^{
                    block should raise_exception.with_reason(reason);
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not raise an exception with reason <%@>", block, reason], ^{
                        block should_not raise_exception.with_reason(reason);
                    });
                });
            });
        });

        context(@"when the block throws an exception with a different reason", ^{
            NSString *anotherReason = @"It's not you, it's me";

            beforeEach(^{
                exception = [NSException exceptionWithName:NSInternalInconsistencyException reason:anotherReason userInfo:nil];
                block = [[^{
                    [exception raise];
                } copy] autorelease];
            });

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to raise an exception with reason <%@>", block, reason], ^{
                        block should raise_exception.with_reason(reason);
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    block should_not raise_exception.with_reason(reason);
                });
            });
        });

        context(@"when the block does not throw an exception", ^{
            beforeEach(^{
                block = [[^{} copy] autorelease];
            });

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to raise an exception with reason <%@>", block, reason], ^{
                        block should raise_exception.with_reason(reason);
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    block should_not raise_exception.with_reason(reason);
                });
            });
        });
    });
});

SPEC_END
