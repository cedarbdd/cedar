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
                    expect(true).to(imply(true));
                });
                
                it(@"should pass", ^{
                    expect(false).to(imply(true));
                });
                
                it(@"should pass", ^{
                    expect(false).to(imply(false));
                });
            });
            
            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <YES> to not imply <YES>", ^{
                        expect(true).to_not(imply(true));
                    });
                });
                
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <NO> to not imply <YES>", ^{
                        expect(false).to_not(imply(true));
                    });
                });

                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <NO> to not imply <NO>", ^{
                        expect(false).to_not(imply(false));
                    });
                });
            });
        });
        
        describe(@"which evaluates to false", ^{
            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <YES> to imply <NO>", ^{
                        expect(true).to(imply(false));
                    });
                });
            });
            
            describe(@"negative match", ^{
                it(@"should should pass", ^{
                    expect(true).to_not(imply(false));
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
                    expect(nil).to(imply(@"wurble"));
                });
                
                it(@"should pass", ^{
                    expect(nil).to(imply(nil));
                });
            });
            
            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <wurble> to not imply <wurble>", ^{
                        expect(@"wurble").to_not(imply(@"wurble"));
                    });
                });
                
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <nil> to not imply <wurble>", ^{
                        expect(nil).to_not(imply(@"wurble"));
                    });
                });
                
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <nil> to not imply <nil>", ^{
                        expect(nil).to_not(imply(nil));
                    });
                });
            });
        });
        
        describe(@"which evaluates to false", ^{
            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <wurble> to imply <nil>", ^{
                        expect(@"wurble").to(imply(nil));
                    });
                });
            });
            
            describe(@"negative match", ^{
                it(@"should should pass", ^{
                    expect(@"wurble").to_not(imply(nil));
                });
            });
        });
    });
    
    describe(@"when the values are mixed", ^{
        describe(@"which evaluates to true", ^{
            describe(@"positive match", ^{
                it(@"should pass", ^{
                    expect(@"wurble").to(imply(true));
                });
                
                it(@"should pass", ^{
                    expect(nil).to(imply(true));
                });
                
                it(@"should pass", ^{
                    expect(nil).to(imply(false));
                });
                
                it(@"should pass", ^{
                    expect(true).to(imply(@"wurble"));
                });
                
                it(@"should pass", ^{
                    expect(false).to(imply(@"wurble"));
                });
                
                it(@"should pass", ^{
                    expect(false).to(imply(nil));
                });
            });
            
            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <wurble> to not imply <YES>", ^{
                        expect(@"wurble").to_not(imply(true));
                    });
                });
                
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <nil> to not imply <YES>", ^{
                        expect(nil).to_not(imply(true));
                    });
                });
                
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <nil> to not imply <NO>", ^{
                        expect(nil).to_not(imply(false));
                    });
                });
                
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <YES> to not imply <wurble>", ^{
                        expect(true).to_not(imply(@"wurble"));
                    });
                });
                
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <NO> to not imply <wurble>", ^{
                        expect(false).to_not(imply(@"wurble"));
                    });
                });
                
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <NO> to not imply <nil>", ^{
                        expect(false).to_not(imply(nil));
                    });
                });
            });
        });
        
        describe(@"which evaluates to false", ^{
            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <wurble> to imply <NO>", ^{
                        expect(@"wurble").to(imply(false));
                    });
                });
                
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <YES> to imply <nil>", ^{
                        expect(true).to(imply(nil));
                    });
                });
            });
            
            describe(@"negative match", ^{
                it(@"should should pass", ^{
                    expect(@"wurble").to_not(imply(false));
                });
                
                it(@"should should pass", ^{
                    expect(true).to_not(imply(nil));
                });
            });
        });
    });
});

SPEC_END
