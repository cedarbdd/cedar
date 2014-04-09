#if TARGET_OS_IPHONE
#import "SpecHelper.h"
#else
#import <Cedar/SpecHelper.h>
#endif

extern "C" {
#import "ExpectFailureWithMessage.h"
}

using namespace Cedar::Matchers;

SPEC_BEGIN(ContainSpec)

describe(@"contain matcher", ^{
    NSString *element = @"element";
    NSString *elementCopy = [[element mutableCopy] autorelease];

    beforeEach(^{
        expect(element).to(equal(elementCopy));
    });

    describe(@"when the container is an STL vector", ^{
        describe(@"which contains the element", ^{
            std::vector<NSString *> container(1, elementCopy);

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(container).to(contain(element));
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <(\n    %@\n)> to not contain <%@>", element, element], ^{
                        expect(container).to_not(contain(element));
                    });
                });
            });
        });

        describe(@"which does not contain the element", ^{
            std::vector<NSString *> container;

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <(\n)> to contain <%@>", element], ^{
                        expect(container).to(contain(element));
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    expect(container).to_not(contain(element));
                });
            });
        });
    });

    describe(@"when the container is an STL map", ^{
        std::map<NSString *, NSString *> container;

        it(@"should explode", ^{
            expectExceptionWithReason(@"Unexpected use of 'contain' matcher with dictionary; use contain_key or contain_value", ^{
                expect(container).to(contain(element));
            });
        });
    });

    describe(@"when the container is an STL set", ^{
        describe(@"which contains the element", ^{
            std::set<NSString *> container;
            container.insert(elementCopy);

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(container).to(contain(element));
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <{(\n    %@\n)}> to not contain <%@>", element, element], ^{
                        expect(container).to_not(contain(element));
                    });
                });
            });
        });

        describe(@"which does not contain the element", ^{
            std::set<NSString *> container;

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <{(\n)}> to contain <%@>", element], ^{
                        expect(container).to(contain(element));
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    expect(container).to_not(contain(element));
                });
            });
        });
    });

    sharedExamplesFor(@"nil container", ^(NSDictionary *sharedContext) {
        id container = nil;

        describe(@"positive match", ^{
            it(@"should should fail", ^{
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to contain <%@>", container, element], ^{
                    expect(container).to(contain(element));
                });
            });
        });
    });

    sharedExamplesFor(@"containing the element", ^(NSDictionary *sharedContext) {
        __block id container;
        beforeEach(^{
            container = [sharedContext objectForKey:@"container"];
        });

        describe(@"positive match", ^{
            it(@"should should pass", ^{
                expect(container).to(contain(element));
            });
        });

        describe(@"negative match", ^{
            it(@"should fail with a sensible failure message", ^{
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not contain <%@>", container, element], ^{
                    expect(container).to_not(contain(element));
                });
            });
        });
    });

    sharedExamplesFor(@"not containing the element", ^(NSDictionary *sharedContext) {
        __block id container;
        beforeEach(^{
            container = [sharedContext objectForKey:@"container_empty"];
        });

        describe(@"positive match", ^{
            it(@"should fail with a sensible failure message", ^{
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to contain <%@>", container, element], ^{
                    expect(container).to(contain(element));
                });
            });
        });

        describe(@"negative match", ^{
            it(@"should pass", ^{
                expect(container).to_not(contain(element));
            });
        });
    });

    sharedExamplesFor(@"containing the element nested", ^(NSDictionary *sharedContext) {
        __block id container;
        beforeEach(^{
            container = [sharedContext objectForKey:@"container_nested"];
        });

        describe(@"positive match", ^{
            it(@"should should pass", ^{
                expect(container).to(contain(element).nested());
            });
        });

        describe(@"negative match", ^{
            it(@"should fail with a sensible failure message", ^{
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not contain <%@> nested", container, element], ^{
                    expect(container).to_not(contain(element).nested());
                });
            });
        });

        describe(@"without the 'nested' modifier", ^{
            it(@"should fail with a sensible failure message", ^{
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to contain <%@>", container, element], ^{
                    expect(container).to(contain(element));
                });
            });
        });
    });

    describe(@"when the container is an NSArray", ^{
        beforeEach(^{
            [[SpecHelper specHelper].sharedExampleContext setObject:[NSArray arrayWithObject:elementCopy] forKey:@"container"];
            [[SpecHelper specHelper].sharedExampleContext setObject:[NSArray array] forKey:@"container_empty"];
            [[SpecHelper specHelper].sharedExampleContext setObject:[NSArray arrayWithObject:[NSArray arrayWithObject:elementCopy]] forKey:@"container_nested"];
        });

        itShouldBehaveLike(@"nil container");
        itShouldBehaveLike(@"containing the element");
        itShouldBehaveLike(@"not containing the element");
        itShouldBehaveLike(@"containing the element nested");
    });

    describe(@"when the container is an NSMutableArray", ^{
        beforeEach(^{
            [[SpecHelper specHelper].sharedExampleContext setObject:[NSMutableArray arrayWithObject:elementCopy] forKey:@"container"];
            [[SpecHelper specHelper].sharedExampleContext setObject:[NSMutableArray array] forKey:@"container_empty"];
            [[SpecHelper specHelper].sharedExampleContext setObject:[NSMutableArray arrayWithObject:[NSMutableArray arrayWithObject:elementCopy]] forKey:@"container_nested"];
        });

        itShouldBehaveLike(@"nil container");
        itShouldBehaveLike(@"containing the element");
        itShouldBehaveLike(@"not containing the element");
        itShouldBehaveLike(@"containing the element nested");
    });

    describe(@"when the container is an NSSet", ^{
        beforeEach(^{
            [[SpecHelper specHelper].sharedExampleContext setObject:[NSSet setWithObject:elementCopy] forKey:@"container"];
            [[SpecHelper specHelper].sharedExampleContext setObject:[NSSet set] forKey:@"container_empty"];
            [[SpecHelper specHelper].sharedExampleContext setObject:[NSSet setWithObject:[NSSet setWithObject:elementCopy]] forKey:@"container_nested"];
        });

        itShouldBehaveLike(@"nil container");
        itShouldBehaveLike(@"containing the element");
        itShouldBehaveLike(@"not containing the element");
        itShouldBehaveLike(@"containing the element nested");
    });

    describe(@"when the container is an NSMutableSet", ^{
        beforeEach(^{
            [[SpecHelper specHelper].sharedExampleContext setObject:[NSMutableSet setWithObject:elementCopy] forKey:@"container"];
            [[SpecHelper specHelper].sharedExampleContext setObject:[NSMutableSet set] forKey:@"container_empty"];
            [[SpecHelper specHelper].sharedExampleContext setObject:[NSMutableSet setWithObject:[NSSet setWithObject:elementCopy]] forKey:@"container_nested"];
        });

        itShouldBehaveLike(@"nil container");
        itShouldBehaveLike(@"containing the element");
        itShouldBehaveLike(@"not containing the element");
        itShouldBehaveLike(@"containing the element nested");
    });

    describe(@"when the container is an NSDictionary", ^{
        NSDictionary *container = [NSDictionary dictionary];

        it(@"should explode", ^{
            expectExceptionWithReason(@"Unexpected use of 'contain' matcher with dictionary; use contain_key or contain_value", ^{
                expect(container).to(contain(element));
            });
        });
    });

    describe(@"when the container is an NSMutableDictionary", ^{
        NSMutableDictionary *container = [NSMutableDictionary dictionary];

        it(@"should explode", ^{
            expectExceptionWithReason(@"Unexpected use of 'contain' matcher with dictionary; use contain_key or contain_value", ^{
                expect(container).to(contain(element));
            });
        });
    });

    describe(@"when the container is a C string", ^{
        describe(@"which is null", ^{
            char *container = NULL;

            describe(@"positive match", ^{
                char *element = (char *)"foo";

                it(@"should fail", ^{
                    expectFailureWithMessage(@"Expected <NULL> to contain <cstring(foo)>", ^{
                        expect(container).to(contain(element));
                    });
                });
            });
        });

        describe(@"which contains the substring", ^{
            char *container = (char *)"jack and jill";
            char *element = (char *)"jack";

            describe(@"positive match", ^{
                it(@"should pass", ^{
                    expect(container).to(contain(element));
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <cstring(jack and jill)> to not contain <cstring(jack)>", ^{
                        expect(container).to_not(contain(element));
                    });
                });
            });
        });

        describe(@"which does not contain the substring", ^{
            char *container = (char *)"batman and robin";
            char *element = (char *)"catwoman";

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <cstring(batman and robin)> to contain <cstring(catwoman)>", ^{
                        expect(container).to(contain(element));
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    expect(container).to_not(contain(element));
                });
            });
        });

        describe(@"with the 'nested' modifier", ^{
            char *container = (char *)"tom and jerry";
            char *element = (char *)"tom";

            it(@"should explode", ^{
                expectExceptionWithReason(@"Unexpected use of 'nested' modifier on 'contain' matcher with string", ^{
                    expect(container).to(contain(element).nested());
                });
            });
        });
    });

    describe(@"when the container is a const C string", ^{
        describe(@"which contains the substring", ^{
            const char *container = (char *)"jack and jill";
            const char *element = (char *)"jack";

            describe(@"positive match", ^{
                it(@"should pass", ^{
                    expect(container).to(contain(element));
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <cstring(jack and jill)> to not contain <cstring(jack)>", ^{
                        expect(container).to_not(contain(element));
                    });
                });
            });
        });

        describe(@"which does not contain the substring", ^{
            const char *container = (char *)"batman and robin";
            const char *element = (char *)"catwoman";

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <cstring(batman and robin)> to contain <cstring(catwoman)>", ^{
                        expect(container).to(contain(element));
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    expect(container).to_not(contain(element));
                });
            });
        });

        describe(@"with the 'nested' modifier", ^{
            const char *container = "tom and jerry";
            const char *element = "tom";

            it(@"should explode", ^{
                expectExceptionWithReason(@"Unexpected use of 'nested' modifier on 'contain' matcher with string", ^{
                    expect(container).to(contain(element).nested());
                });
            });
        });
    });

    describe(@"when the container is an NSString", ^{
        describe(@"which is nil", ^{
            NSString *container = nil;

            describe(@"positive match", ^{
                it(@"should should fail", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to contain <%@>", container, element], ^{
                        expect(container).to(contain(element));
                    });
                });
            });
        });


        describe(@"which contains the substring", ^{
            NSString *container = @"A string that contains element";

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(container).to(contain(element));
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not contain <%@>", container, element], ^{
                        expect(container).to_not(contain(element));
                    });
                });
            });
        });

        describe(@"which does not contain the substring", ^{
            NSString *container = @"I contain nothing!";

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to contain <%@>", container, element], ^{
                        expect(container).to(contain(element));
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    expect(container).to_not(contain(element));
                });
            });
        });

        describe(@"with the 'nested' modifier", ^{
            NSString *container = @"tom and jerry";
            NSString *element = @"tom";

            it(@"should explode", ^{
                expectExceptionWithReason(@"Unexpected use of 'nested' modifier on 'contain' matcher with string", ^{
                    expect(container).to(contain(element).nested());
                });
            });
        });
    });

    describe(@"when the container is an NSMutableString", ^{
        describe(@"which is nil", ^{
            NSMutableString *container = nil;

            describe(@"positive match", ^{
                it(@"should should fail", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to contain <%@>", container, element], ^{
                        expect(container).to(contain(element));
                    });
                });
            });
        });


        describe(@"which contains the substring", ^{
            NSMutableString *container = [[@"A string that contains element" mutableCopy] autorelease];

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(container).to(contain(element));
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not contain <%@>", container, element], ^{
                        expect(container).to_not(contain(element));
                    });
                });
            });
        });

        describe(@"which does not contain the substring", ^{
            NSMutableString *container = [[@"I contain nothing!" mutableCopy] autorelease];

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to contain <%@>", container, element], ^{
                        expect(container).to(contain(element));
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    expect(container).to_not(contain(element));
                });
            });
        });

        describe(@"with the 'nested' modifier", ^{
            NSMutableString *container = [[@"A string that contains element" mutableCopy] autorelease];

            it(@"should explode", ^{
                expectExceptionWithReason(@"Unexpected use of 'nested' modifier on 'contain' matcher with string", ^{
                    expect(container).to(contain(element).nested());
                });
            });
        });

    });
});

SPEC_END
