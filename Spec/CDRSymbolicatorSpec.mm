#import "Cedar.h"
#import "CDRSymbolicator.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(CDRSymbolicatorSpec)

describe(@"CDRSymbolicator", ^{
    __block CDRSymbolicator *symbolicator;

    beforeEach(^{
        symbolicator = [[[CDRSymbolicator alloc] init] autorelease];
    });

#if !CDR_SYMBOLICATION_AVAILABLE
    context(@"when symbolication is not available (devices and watchOS)", ^{
        __block NSArray *addresses;
        __block NSError *error;

        beforeEach(^{
            NSNumber *address = [NSNumber numberWithUnsignedInteger:123];
            addresses = [NSArray arrayWithObject:address];
        });

        subjectAction(^{
            error = nil;
            [symbolicator symbolicateAddresses:addresses error:&error];
        });

        it(@"does not return filename or line number", ^{
            [symbolicator fileNameForStackAddress:0] should be_nil;
            [symbolicator lineNumberForStackAddress:0] should equal(0);
        });

        it(@"sets not available error", ^{
            error.domain should equal(kCDRSymbolicatorErrorDomain);
            error.code should equal(kCDRSymbolicatorErrorNotAvailable);
            [error.userInfo objectForKey:kCDRSymbolicatorErrorMessageKey] \
                should be_instance_of([NSString class]).or_any_subclass();
        });
    });
#else
    context(@"when symbolication is available (osx, simulator)", ^{
        context(@"when symbolication is successful", ^{
            __block CDRExample *example;
            __block CDRExampleGroup *group;

            void (^verifyFileNameAndLineNumber)(CDRExampleBase *, NSString *, int) =
                ^(CDRExampleBase *b, NSString *fileName, int lineNumber) {
                    NSNumber *address = [NSNumber numberWithUnsignedInteger:b.stackAddress];
                    NSArray *addresses = [NSArray arrayWithObject:address];

                    NSError *error = nil;
                    [symbolicator symbolicateAddresses:addresses error:&error] should be_truthy;
                    error should be_nil;

                    [[symbolicator fileNameForStackAddress:b.stackAddress] hasSuffix:fileName] should be_truthy;
                    [symbolicator lineNumberForStackAddress:b.stackAddress] should equal(lineNumber);
                };

            it(@"identifies file name and line number of an it", ^{
                example = it(@"it", ^{});
                verifyFileNameAndLineNumber(example, @"CDRSymbolicatorSpec.mm", __LINE__-1);
            });

            it(@"identifies file name line number of a describe", ^{
                group = describe(@"describe", ^{});
                verifyFileNameAndLineNumber(group, @"CDRSymbolicatorSpec.mm", __LINE__-1);
            });

            it(@"identifies file name line number of a context", ^{
                group = context(@"context", ^{});
                verifyFileNameAndLineNumber(group, @"CDRSymbolicatorSpec.mm", __LINE__-1);
            });

            it(@"identifies file name line number of a nested it", ^{
                describe(@"describe", ^{
                    example = it(@"it", ^{});
                });
                verifyFileNameAndLineNumber(example, @"CDRSymbolicatorSpec.mm", __LINE__-2);
            });

            it(@"identifies file name line number of a nested describe", ^{
                describe(@"describe", ^{
                    group = describe(@"describe", ^{});
                });
                verifyFileNameAndLineNumber(group, @"CDRSymbolicatorSpec.mm", __LINE__-2);
            });

            it(@"identifies file name line number of a nested context", ^{
                describe(@"describe", ^{
                    group = context(@"context", ^{});
                });
                verifyFileNameAndLineNumber(group, @"CDRSymbolicatorSpec.mm", __LINE__-2);
            });
        });

        context(@"when symbolication is not successful", ^{
            __block NSArray *addresses;
            __block NSError *error;

            beforeEach(^{
                NSNumber *badAddress = [NSNumber numberWithUnsignedInteger:123];
                addresses = [NSArray arrayWithObject:badAddress];
            });

            subjectAction(^{
                error = nil;
                [symbolicator symbolicateAddresses:addresses error:&error] should be_falsy;
            });

            it(@"does not return filename or line number", ^{
                [symbolicator fileNameForStackAddress:0] should be_nil;
                [symbolicator lineNumberForStackAddress:0] should equal(0);
            });

            it(@"sets not successful error", ^{
                error.domain should equal(kCDRSymbolicatorErrorDomain);
                error.code should equal(kCDRSymbolicatorErrorNotSuccessful);
                [error.userInfo objectForKey:kCDRSymbolicatorErrorMessageKey] \
                    should be_instance_of([NSString class]).or_any_subclass();
            });
        });
    });
#endif
});

SPEC_END
