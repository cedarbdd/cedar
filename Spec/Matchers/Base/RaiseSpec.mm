#if TARGET_OS_IPHONE
#import <Cedar/SpecHelper.h>
#import "OCMock.h"
#else
#import <Cedar/SpecHelper.h>
#import <OCMock/OCMock.h>
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

SPEC_BEGIN(RaiseSpec)

describe(@"raise matcher", ^{
    __block void (^block)();
    __block NSException *exception;

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
                it(@"should should pass", ^{
                    block should raise(expectedExceptionClass);
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <specified block> to not raise an exception of type <%@>", NSStringFromClass(expectedExceptionClass)], ^{
                        block should_not raise(expectedExceptionClass);
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
                    it(@"should should pass", PENDING); //^{
//                        block should raise(expectedExceptionClass).or_subclass();
//                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", PENDING); //^{
//                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <specified block> to not raise an exception of type, or subclass of type, <%@>", NSStringFromClass([expectedExceptionClass class])], ^{
//                            block should_not raise(expectedExceptionClass).or_subclass();
//                        });
//                    });
                });
            });

            context(@"when subclass exceptions are not expected", ^{
                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <specified block> to raise an exception of type <%@>", NSStringFromClass([expectedExceptionClass class])], ^{
                            block should raise(expectedExceptionClass);
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should should pass", ^{
                        block should_not raise(expectedExceptionClass);
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
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <specified block> to raise an exception of type <%@>", NSStringFromClass([expectedExceptionClass class])], ^{
                        block should raise(expectedExceptionClass);
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should should pass", ^{
                    block should_not raise(expectedExceptionClass);
                });
            });
        });

        context(@"when the block does not throw an exception", ^{
            beforeEach(^{
                block = [[^{} copy] autorelease];
            });

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <specified block> to raise an exception of type <%@>", NSStringFromClass([expectedExceptionClass class])], ^{
                        block should raise(expectedExceptionClass);
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should should pass", ^{
                    block should_not raise(expectedExceptionClass);
                });
            });
        });
    });

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
                    it(@"should should pass", ^{
                        block should raise();
                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <specified block> to not raise an exception", ^{
                            block should_not raise();
                        });
                    });
                });
            });

            context(@"when called without parentheses", ^{
                describe(@"positive match", ^{
                    it(@"should should pass", PENDING); //^{
//                        block should raise;
//                    });
                });

                describe(@"negative match", ^{
                    it(@"should fail with a sensible failure message", PENDING); //^{
//                        expectFailureWithMessage(@"Expected <specified block> to not raise an exception", ^{
//                            block should_not raise;
//                        });
//                    });
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
                        expectFailureWithMessage(@"Expected <specified block> to raise an exception", ^{
                            block should raise();
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should should pass", ^{
                        block should_not raise();
                    });
                });
            });

            context(@"when called without parentheses", ^{
                describe(@"positive match", ^{
                    it(@"should fail with a sensible failure message", PENDING); //^{
//                        expectFailureWithMessage(@"Expected <specified block> to raise an exception", ^{
//                            block should raise;
//                        });
//                    });
                });

                describe(@"negative match", ^{
                    it(@"should should pass", PENDING); //^{
//                        block should_not raise;
//                    });
                });
            });
        });
    });
});

SPEC_END
