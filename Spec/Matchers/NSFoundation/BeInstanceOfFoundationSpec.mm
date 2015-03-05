#if TARGET_OS_IPHONE
#import <Cedar/CDRSpecHelper.h>
#else
#import <Cedar/CDRSpecHelper.h>
#endif

extern "C" {
#import "ExpectFailureWithMessage.h"
}


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(BeInstanceOfFoundationSpec)

describe(@"Be instance of Foundation matchers", ^{
    describe(@"NSString matchers", ^{
        describe(@"positive match", ^{
            it(@"exact class should pass", ^{
                NSString * constString = @"constString";
                constString should be_string;
            });

            it(@"subclass should pass", ^{
                NSMutableString * mutableString = [NSMutableString string];
                mutableString should be_string;
            });
        });

        describe(@"negative mathc", ^{
            it(@"should fail with a sensible failure message", ^{
                expectFailureWithMessage(@"Expected <<null> (NSNull)> to be an instance of class <NSString>, or any of its subclasses", ^{
                    NSNull * null = [NSNull null];
                    null should be_string;
                });
            });
        });
    });

    describe(@"NSNumber matchers", ^{
        describe(@"positive match", ^{
            it(@"exact class should pass", ^{
                NSNumber * constNumber = @42;
                constNumber should be_number;
            });

            it(@"subclass should pass", ^{
                NSDecimalNumber * decimalNumber = [NSDecimalNumber maximumDecimalNumber];
                decimalNumber should be_number;
            });
        });

        describe(@"negative mathc", ^{
            it(@"should fail with a sensible failure message", ^{
                expectFailureWithMessage(@"Expected <<null> (NSNull)> to be an instance of class <NSNumber>, or any of its subclasses", ^{
                    NSNull * null = [NSNull null];
                    null should be_number;
                });
            });
        });
    });

    describe(@"NSArray matchers", ^{
        describe(@"positive match", ^{
            it(@"exact class should pass", ^{
                NSArray * array = @[];
                array should be_array;
            });

            it(@"subclass should pass", ^{
                NSMutableArray * mutableArray = [NSMutableArray array];
                mutableArray should be_array;
            });
        });

        describe(@"negative mathc", ^{
            it(@"should fail with a sensible failure message", ^{
                expectFailureWithMessage(@"Expected <<null> (NSNull)> to be an instance of class <NSArray>, or any of its subclasses", ^{
                    NSNull * null = [NSNull null];
                    null should be_array;
                });
            });
        });
    });

    describe(@"NSDictionary matchers", ^{
        describe(@"positive match", ^{
            it(@"exact class should pass", ^{
                NSDictionary * dictionary = @{};
                dictionary should be_dictionary;
            });

            it(@"subclass should pass", ^{
                NSMutableDictionary * mutableDictionary = [NSMutableDictionary dictionary];
                mutableDictionary should be_dictionary;
            });
        });

        describe(@"negative mathc", ^{
            it(@"should fail with a sensible failure message", ^{
                expectFailureWithMessage(@"Expected <<null> (NSNull)> to be an instance of class <NSDictionary>, or any of its subclasses", ^{
                    NSNull * null = [NSNull null];
                    null should be_dictionary;
                });
            });
        });
    });
});

SPEC_END
