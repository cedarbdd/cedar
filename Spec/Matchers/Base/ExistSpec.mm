#import "Cedar.h"
#import "ExpectFailureWithMessage.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(ExistSpec)

NSFileManager *fileManager = [NSFileManager defaultManager];
NSURL *cacheURL = [[fileManager URLsForDirectory:NSCachesDirectory
                                       inDomains:NSUserDomainMask] objectAtIndex:0];
describe(@"exist matcher", ^{
    if (![fileManager fileExistsAtPath:cacheURL.path]) {
        [fileManager createDirectoryAtPath:cacheURL.path
               withIntermediateDirectories:YES
                                attributes:@{}
                                     error:NULL] should be_truthy;
    }
    describe(@"when the actual value is an NSURL *", ^{
        __block NSURL *URL;

        context(@"pointing to a resource that exists on the filesystem", ^{
            beforeEach(^{
                URL = [cacheURL URLByAppendingPathComponent:@"data.file"];
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

    describe(@"when the actual value is an NSString *", ^{
        __block NSString *path;

        context(@"pointing to a file path that exists", ^{
            beforeEach(^{
                path = [cacheURL URLByAppendingPathComponent:@"data.file"].path;

                [@"I exist." writeToFile:path
                              atomically:YES
                                encoding:NSUTF8StringEncoding
                                   error:NULL] should be_truthy;
            });

            it(@"should pass for a file", ^{
                expect(path).to(exist);
            });

            it(@"should pass for a directory", ^{
                cacheURL.path should exist;
            });

            afterEach(^{
                [fileManager removeItemAtPath:path error:NULL] should be_truthy;
            });
        });

        context(@"pointing to a nonexistent file path", ^{
            beforeEach(^{
                path = @"/foo/bar/baz";
            });

            it(@"should fail with a sensible failure message", ^{
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to exist on the local filesystem", path], ^{
                    expect(path).to(exist);
                });
            });
        });

        context(@"pointing to a non-filesystem resource", ^{
            beforeEach(^{
                path = @"http://zombo.com";
            });

            it(@"should fail with a sensible failure message", ^{
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to exist on the local filesystem", path], ^{
                    expect(path).to(exist);
                });
            });
        });
    });
});

SPEC_END
