#if TARGET_OS_IPHONE
#import <Cedar/CDRSpecHelper.h>
#else
#import <Cedar/CDRSpecHelper.h>
#endif

extern "C" {
#import "ExpectFailureWithMessage.h"
}

using namespace Cedar::Matchers;

SPEC_BEGIN(ImplySpec)

describe(@"implies matcher", ^{
    describe(@"when the values are built-in type", ^{
        describe(@"which evaluates to true", ^{
            describe(@"positive match", ^{
                it(@"should pass", ^{
                    expect(YES).to(imply(YES));
                });
                
                it(@"should pass", ^{
                    expect(NO).to(imply(YES));
                });
                
                it(@"should pass", ^{
                    expect(NO).to(imply(NO));
                });
            });
            
            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <YES> to not imply <YES>", ^{
                        expect(YES).to_not(imply(YES));
                    });
                });
                
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <NO> to not imply <YES>", ^{
                        expect(NO).to_not(imply(YES));
                    });
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <NO> to not imply <NO>", ^{
                        expect(NO).to_not(imply(NO));
                    });
                });
            });
        });
        
        describe(@"which evaluates to false", ^{
            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <YES> to imply <NO>", ^{
                        expect(YES).to(imply(NO));
                    });
                });
            });
            
            describe(@"negative match", ^{
                it(@"should should pass", ^{
                    expect(YES).to_not(imply(NO));
                });
            });
        });
    });
    
    describe(@"when the value is an id", ^{
        describe(@"which evaluates to true", ^{
            describe(@"positive match", ^{
                it(@"should pass", ^{
                    expect(@"wurble").to(imply(@"wurble"));
                });
                
                it(@"should pass", ^{
                    expect((id)nil).to(imply(@"wurble"));
                });
                
                it(@"should pass", ^{
                    expect((id)nil).to(imply((id)nil));
                });
            });
            
            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <wurble> to not imply <wurble>", ^{
                        expect(@"wurble").to_not(imply(@"wurble"));
                    });
                });
                
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <(null)> to not imply <wurble>", ^{
                        expect((id)nil).to_not(imply(@"wurble"));
                    });
                });
                
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <(null)> to not imply <(null)>", ^{
                        expect((id)nil).to_not(imply((id)nil));
                    });
                });
            });
        });
        
        describe(@"which evaluates to false", ^{
            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <wurble> to imply <(null)>", ^{
                        expect(@"wurble").to(imply((id)nil));
                    });
                });
            });
            
            describe(@"negative match", ^{
                it(@"should should pass", ^{
                    expect(@"wurble").to_not(imply((id)nil));
                });
            });
        });
    });
    
    describe(@"when the values are mixed", ^{
        describe(@"which evaluates to true", ^{
            describe(@"positive match", ^{
                it(@"should pass", ^{
                    expect(@"wurble").to(imply(YES));
                });
                
                it(@"should pass", ^{
                    expect((id)nil).to(imply(YES));
                });
                
                it(@"should pass", ^{
                    expect((id)nil).to(imply(NO));
                });
                
                it(@"should pass", ^{
                    expect(YES).to(imply(@"wurble"));
                });
                
                it(@"should pass", ^{
                    expect(NO).to(imply(@"wurble"));
                });
                
                it(@"should pass", ^{
                    expect(NO).to(imply((id)nil));
                });
            });
            
            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <wurble> to not imply <YES>", ^{
                        expect(@"wurble").to_not(imply(YES));
                    });
                });
                
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <(null)> to not imply <YES>", ^{
                        expect((id)nil).to_not(imply(YES));
                    });
                });
                
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <(null)> to not imply <NO>", ^{
                        expect((id)nil).to_not(imply(NO));
                    });
                });
                
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <YES> to not imply <wurble>", ^{
                        expect(YES).to_not(imply(@"wurble"));
                    });
                });
                
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <NO> to not imply <wurble>", ^{
                        expect(NO).to_not(imply(@"wurble"));
                    });
                });
                
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <NO> to not imply <(null)>", ^{
                        expect(NO).to_not(imply((id)nil));
                    });
                });
            });
        });
        
        describe(@"which evaluates to false", ^{
            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <wurble> to imply <NO>", ^{
                        expect(@"wurble").to(imply(NO));
                    });
                });
                
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <YES> to imply <(null)>", ^{
                        expect(YES).to(imply((id)nil));
                    });
                });
            });
            
            describe(@"negative match", ^{
                it(@"should should pass", ^{
                    expect(@"wurble").to_not(imply(NO));
                });
                
                it(@"should should pass", ^{
                    expect(YES).to_not(imply((id)nil));
                });
            });
        });
    });
});

SPEC_END
