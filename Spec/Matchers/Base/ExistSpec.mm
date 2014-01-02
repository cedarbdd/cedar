#if TARGET_OS_IPHONE
#import <Cedar/SpecHelper.h>
#else
#import <Cedar/SpecHelper.h>
#endif

extern "C" {
#import "ExpectFailureWithMessage.h"
}

using namespace Cedar::Matchers;

SPEC_BEGIN(ExistSpec)

describe(@"exist matcher", ^{
    describe(@"when the actual value is an NSURL *", ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *cacheURL = [fileManager URLsForDirectory:NSCachesDirectory
                                              inDomains:NSUserDomainMask][0];

        __block NSURL *URL;
        context(@"pointing to a resource that exists on the filesystem", ^{
            beforeEach(^{
                URL = [cacheURL URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
                [URL isFileURL] should be_truthy;

                [@"I exist." writeToFile:URL.path
                              atomically:YES
                                encoding:NSUTF8StringEncoding
                                   error:NULL] should be_truthy;
            });

            it(@"should pass for a file", ^{
                expect(URL).to(exist);
            });

            it(@"should pass for a directory", ^{
                cacheURL should exist;
            });

            afterEach(^{
                [fileManager removeItemAtURL:URL error:NULL] should be_truthy;
            });
        });

        context(@"pointing to a nonexistent filesystem resource", ^{
            beforeEach(^{
                URL = [NSURL fileURLWithPath:@"/foo/bar/baz"];
                [URL isFileURL] should be_truthy;
            });

            it(@"should fail with a sensible failure message", ^{
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to exist on the local filesystem", URL], ^{
                    expect(URL).to(exist);
                });
            });
        });

        context(@"pointing to a non-filesystem resource", ^{
            beforeEach(^{
                URL = [NSURL URLWithString:@"http://zombo.com"];
                [URL isFileURL] should_not be_truthy;
            });

            it(@"should fail with a sensible failure message", ^{
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to exist on the local filesystem", URL], ^{
                    expect(URL).to(exist);
                });
            });
        });
    });

    xdescribe(@"when the actual value is an NSString *", ^{});
});


SPEC_END
