#import <Cedar/Cedar.h>
#import "ExpectFailureWithMessage.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(BlockMatcherSpec)

describe(@"BlockMatcher", ^{

    context(@"when the matcher is typed as 'id'", ^{
        id expectedSubject = @"subj";

        context(@"and the subject is typed as 'id'", ^{
            __block id actualSubject;

            context(@"when no failure message is provided", ^{
                auto be_a_match = expectationVerifier(^(id subject){
                    return [subject isEqual:expectedSubject];
                }).matcher();

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        actualSubject = @"subj";
                        actualSubject should be_a_match;
                    });

                    it(@"should fail with the returned failure message", ^{
                        actualSubject = @"other";
                        expectFailureWithMessage(@"Expected <other> to pass a test", ^{
                            actualSubject should be_a_match;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        actualSubject = @"other";
                        actualSubject should_not be_a_match;
                    });

                    it(@"should fail with the returned failure message", ^{
                        actualSubject = @"subj";
                        expectFailureWithMessage(@"Expected <subj> to not pass a test", ^{
                            actualSubject should_not be_a_match;
                        });
                    });
                });
            });

            context(@"when a failure message string is provided", ^{
                CedarBlockMatcher<id> be_a_match = expectationVerifier(^(id subject){
                    return [subject isEqual:expectedSubject];
                }).with_failure_message_end(@"be a match").matcher();

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        actualSubject = @"subj";
                        actualSubject should be_a_match;
                    });

                    it(@"should fail with the returned failure message", ^{
                        actualSubject = @"other";
                        expectFailureWithMessage(@"Expected <other> to be a match", ^{
                            actualSubject should be_a_match;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        actualSubject = @"other";
                        actualSubject should_not be_a_match;
                    });

                    it(@"should fail with the returned failure message", ^{
                        actualSubject = @"subj";
                        expectFailureWithMessage(@"Expected <subj> to not be a match", ^{
                            actualSubject should_not be_a_match;
                        });
                    });
                });
            });

            context(@"when a failure message block is provided", ^{
                auto be_a_match = expectationVerifier(^(id subject){
                    return [subject isEqual:expectedSubject];
                }).with_failure_message_end(^{ return @"be a perfect match"; }).matcher();

                describe(@"positive match", ^{
                    it(@"should pass", ^{
                        actualSubject = @"subj";
                        actualSubject should be_a_match;
                    });

                    it(@"should fail with the returned failure message", ^{
                        actualSubject = @"other";
                        expectFailureWithMessage(@"Expected <other> to be a perfect match", ^{
                            actualSubject should be_a_match;
                        });
                    });
                });

                describe(@"negative match", ^{
                    it(@"should pass", ^{
                        actualSubject = @"other";
                        actualSubject should_not be_a_match;
                    });

                    it(@"should fail with the returned failure message", ^{
                        actualSubject = @"subj";
                        expectFailureWithMessage(@"Expected <subj> to not be a perfect match", ^{
                            actualSubject should_not be_a_match;
                        });
                    });
                });
            });
        });

        context(@"and the subject is typed as an object subclass", ^{
            auto be_a_match = expectationVerifier(^(id subject){
                return [subject isEqual:expectedSubject];
            }).matcher();
            __block NSString *actualSubject;

            it(@"should pass", ^{
                actualSubject = @"subj";
                actualSubject should be_a_match;
            });
        });
    });

    context(@"when the matcher is typed as an object subclass", ^{
        NSString *expectedSubject = @"subj";
        auto be_a_match = expectationVerifier(^(NSString *subject){
            return [subject isEqual:expectedSubject];
        }).matcher();

        context(@"and the subject has the same type", ^{
            it(@"should pass", ^{
                NSString *actualSubject = @"subj";
                actualSubject should be_a_match;
            });
        });

        context(@"and the subject is a subclass of the matcher's type", ^{
            it(@"should pass", ^{
                NSMutableString *actualSubject = [@"subj" mutableCopy];
                actualSubject should be_a_match;
            });
        });
    });

    context(@"when the subject is a primitive", ^{
        NSInteger expectedSubject = 42;

        auto be_a_match = expectationVerifier(^(NSInteger subject){
            return subject == expectedSubject;
        }).matcher();

        describe(@"positive match", ^{
            it(@"should pass", ^{
                42 should be_a_match;
            });

            it(@"should fail with the returned failure message", ^{
                expectFailureWithMessage(@"Expected <999> to pass a test", ^{
                    999 should be_a_match;
                });
            });
        });

        describe(@"negative match", ^{
            it(@"should pass", ^{
                999 should_not be_a_match;
            });

            it(@"should fail with the returned failure message", ^{
                expectFailureWithMessage(@"Expected <42> to not pass a test", ^{
                    42 should_not be_a_match;
                });
            });
        });
    });

    describe(@"builder shorthand", ^{
        it(@"should allow building a matcher via implicit conversion", ^{
            CedarBlockMatcher<id> pass = expectationVerifier(^(id subject){
                return true;
            });

            @"hi" should pass;
        });

        it(@"should allow building a matcher including failure_message_end with a single function call", ^{
            auto be_cute = matcherFor(@"be cute", ^(NSString *subject){
                return [[subject lowercaseString] rangeOfString:@"kitten"].location != NSNotFound;
            });

            @"kittens" should be_cute;
            expectFailureWithMessage(@"Expected <snakes> to be cute", ^{
                @"snakes" should be_cute;
            });
        });
    });
});

SPEC_END
