#import "Cedar.h"
#import "ExpectFailureWithMessage.h"

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

        describe(@"matching based on object class", ^{
            std::vector<NSString *> container(1, elementCopy);

            describe(@"positive match", ^{
                it(@"should pass when checking for an instance of the exact class", ^{
                    expect(container).to(contain(an_instance_of([elementCopy class])));
                });

                it(@"should not pass when checking for an instance of a superclass", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <(\n    %@\n)> to contain <an instance of NSObject>", element], ^{
                        expect(container).to(contain(an_instance_of([NSObject class])));
                    });
                });

                context(@"when including subclasses", ^{
                    it(@"should pass when checking for an instance of a superclass", ^{
                        expect(container).to(contain(an_instance_of([NSObject class]).or_any_subclass()));
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <(\n    %@\n)> to not contain <an instance of %@>", element, [elementCopy class]], ^{
                        expect(container).to_not(contain(an_instance_of([elementCopy class])));
                    });
                });
            });
        });

        describe(@"with modifiers", ^{
            std::vector<NSString *> container;

            it(@"should not allow the as_a_key() modifier", ^{
                expectExceptionWithReason(@"Unexpected use of the .as_a_key() modifier on the 'contain' matcher without a dictionary", ^{
                    expect(container).to(contain(element).as_a_key());
                });
            });

            it(@"should not allow the as_a_value() modifier", ^{
                expectExceptionWithReason(@"Unexpected use of the .as_a_value() modifier on the 'contain' matcher without a dictionary", ^{
                    expect(container).to(contain(element).as_a_value());
                });
            });
        });
    });

    describe(@"when the container is an STL map", ^{
        std::map<NSString *, NSString *> container;
        container[@"aKey"] = elementCopy;

        context(@"plain containment", ^{
            context(@"when matching a specific object", ^{
                it(@"should explode", ^{
                    expectExceptionWithReason(@"Unexpected use of 'contain' matcher with dictionary; use the .as_a_key() or .as_a_value() modifiers", ^{
                        expect(container).to(contain(element));
                    });
                });
            });
        });

        context(@"matching key containment", ^{
            context(@"when matching a specific object", ^{
                context(@"positive match", ^{
                    it(@"should find the specified key", ^{
                        expect(container).to(contain(@"aKey").as_a_key());
                    });
                });

                context(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage(@"Expected <{\n    aKey = element;\n}> to not contain <aKey> nested as a key", ^{
                            expect(container).to_not(contain(@"aKey").nested().as_a_key());
                        });
                    });
                });
            });

            context(@"when matching a class", ^{
                it(@"should find the matching class within the keys", ^{
                    expect(container).to(contain(an_instance_of([@"aKey" class])).as_a_key());
                });
            });
        });

        context(@"matching value containment", ^{
            context(@"when matching a specific object", ^{
                context(@"positive match", ^{
                    it(@"should find the specified key", ^{
                        expect(container).to(contain(elementCopy).as_a_value());
                    });
                });

                context(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <{\n    aKey = element;\n}> to not contain <%@> nested as a value", element], ^{
                            expect(container).to_not(contain(element).nested().as_a_value());
                        });
                    });
                });
            });

            context(@"when matching a class", ^{
                it(@"should find the matching class within the keys", ^{
                    expect(container).to(contain(an_instance_of([elementCopy class])).as_a_value());
                });
            });
        });

        context(@"with invalid modifiers", ^{
            it(@"should not allow both the as_a_key() and as_a_value() modifiers together", ^{
                expectExceptionWithReason(@"Unexpected use of 'contain' matcher; use the .as_a_key() or .as_a_value() modifiers, but not both", ^{
                    expect(container).to(contain(@"aKey").as_a_key().as_a_value());
                });
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

            it(@"should not allow the as_a_key() modifier", ^{
                expectExceptionWithReason(@"Unexpected use of the .as_a_key() modifier on the 'contain' matcher without a dictionary", ^{
                    expect(container).to(contain(element).as_a_key());
                });
            });

            it(@"should not allow the as_a_value() modifier", ^{
                expectExceptionWithReason(@"Unexpected use of the .as_a_value() modifier on the 'contain' matcher without a dictionary", ^{
                    expect(container).to(contain(element).as_a_value());
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

        describe(@"matching based on object class", ^{
            std::set<NSString *> container;
            container.insert(elementCopy);

            describe(@"positive match", ^{
                it(@"should pass when checking for an instance of the exact class", ^{
                    expect(container).to(contain(an_instance_of([elementCopy class])));
                });

                it(@"should not pass when checking for an instance of a superclass", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <{(\n    %@\n)}> to contain <an instance of NSObject>", element], ^{
                        expect(container).to(contain(an_instance_of([NSObject class])));
                    });
                });

                context(@"when including subclasses", ^{
                    it(@"should pass when checking for an instance of a superclass", ^{
                        expect(container).to(contain(an_instance_of([NSObject class]).or_any_subclass()));
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <{(\n    %@\n)}> to not contain <an instance of %@>", element, [elementCopy class]], ^{
                        expect(container).to_not(contain(an_instance_of([elementCopy class])));
                    });
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

        it(@"should not allow the as_a_key() modifier", ^{
            expectExceptionWithReason(@"Unexpected use of the .as_a_key() modifier on the 'contain' matcher without a dictionary", ^{
                expect(container).to(contain(element).as_a_key());
            });
        });

        it(@"should not allow the as_a_value() modifier", ^{
            expectExceptionWithReason(@"Unexpected use of the .as_a_value() modifier on the 'contain' matcher without a dictionary", ^{
                expect(container).to(contain(element).as_a_value());
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

    sharedExamplesFor(@"matching based on object class", ^(NSDictionary *sharedContext) {
        __block id container;
        beforeEach(^{
            container = sharedContext[@"container"];
        });

        describe(@"positive match", ^{
            it(@"should pass when checking for an instance of the exact class", ^{
                expect(container).to(contain(an_instance_of([elementCopy class])));
            });

            it(@"should not pass when checking for an instance of a superclass", ^{
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to contain <an instance of NSObject>", container], ^{
                    expect(container).to(contain(an_instance_of([NSObject class])));
                });
            });

            context(@"when including subclasses", ^{
                it(@"should pass when checking for an instance of a superclass", ^{
                    expect(container).to(contain(an_instance_of([NSObject class]).or_any_subclass()));
                });

                it(@"should not pass when checking for a different class", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to contain <an instance of NSNumber or any subclass>", container], ^{
                        expect(container).to(contain(an_instance_of([NSNumber class]).or_any_subclass()));
                    });
                });
            });
        });

        describe(@"negative match", ^{
            it(@"should fail with a sensible failure message", ^{
                expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not contain <an instance of %@>", container, [elementCopy class]], ^{
                    expect(container).to_not(contain(an_instance_of([elementCopy class])));
                });
            });
        });
    });

    describe(@"when the container is an NSArray", ^{
        beforeEach(^{
            [[CDRSpecHelper specHelper].sharedExampleContext setObject:[NSArray arrayWithObject:elementCopy] forKey:@"container"];
            [[CDRSpecHelper specHelper].sharedExampleContext setObject:[NSArray array] forKey:@"container_empty"];
            [[CDRSpecHelper specHelper].sharedExampleContext setObject:[NSArray arrayWithObject:[NSArray arrayWithObject:elementCopy]] forKey:@"container_nested"];
        });

        itShouldBehaveLike(@"nil container");
        itShouldBehaveLike(@"containing the element");
        itShouldBehaveLike(@"not containing the element");
        itShouldBehaveLike(@"containing the element nested");
        itShouldBehaveLike(@"matching based on object class");
    });

    describe(@"when the container is an NSMutableArray", ^{
        beforeEach(^{
            [[CDRSpecHelper specHelper].sharedExampleContext setObject:[NSMutableArray arrayWithObject:elementCopy] forKey:@"container"];
            [[CDRSpecHelper specHelper].sharedExampleContext setObject:[NSMutableArray array] forKey:@"container_empty"];
            [[CDRSpecHelper specHelper].sharedExampleContext setObject:[NSMutableArray arrayWithObject:[NSMutableArray arrayWithObject:elementCopy]] forKey:@"container_nested"];
        });

        itShouldBehaveLike(@"nil container");
        itShouldBehaveLike(@"containing the element");
        itShouldBehaveLike(@"not containing the element");
        itShouldBehaveLike(@"containing the element nested");
        itShouldBehaveLike(@"matching based on object class");
    });

    describe(@"when the container is an NSSet", ^{
        beforeEach(^{
            [[CDRSpecHelper specHelper].sharedExampleContext setObject:[NSSet setWithObject:elementCopy] forKey:@"container"];
            [[CDRSpecHelper specHelper].sharedExampleContext setObject:[NSSet set] forKey:@"container_empty"];
            [[CDRSpecHelper specHelper].sharedExampleContext setObject:[NSSet setWithObject:[NSSet setWithObject:elementCopy]] forKey:@"container_nested"];
        });

        itShouldBehaveLike(@"nil container");
        itShouldBehaveLike(@"containing the element");
        itShouldBehaveLike(@"not containing the element");
        itShouldBehaveLike(@"containing the element nested");
        itShouldBehaveLike(@"matching based on object class");
    });

    describe(@"when the container is an NSMutableSet", ^{
        beforeEach(^{
            [[CDRSpecHelper specHelper].sharedExampleContext setObject:[NSMutableSet setWithObject:elementCopy] forKey:@"container"];
            [[CDRSpecHelper specHelper].sharedExampleContext setObject:[NSMutableSet set] forKey:@"container_empty"];
            [[CDRSpecHelper specHelper].sharedExampleContext setObject:[NSMutableSet setWithObject:[NSSet setWithObject:elementCopy]] forKey:@"container_nested"];
        });

        itShouldBehaveLike(@"nil container");
        itShouldBehaveLike(@"containing the element");
        itShouldBehaveLike(@"not containing the element");
        itShouldBehaveLike(@"containing the element nested");
        itShouldBehaveLike(@"matching based on object class");
    });

    describe(@"when the container is an NSDictionary", ^{
        context(@"plain containment", ^{
            NSDictionary *container = [NSDictionary dictionary];

            context(@"when matching a specific object", ^{
                it(@"should explode", ^{
                    expectExceptionWithReason(@"Unexpected use of 'contain' matcher with dictionary; use the .as_a_key() or .as_a_value() modifiers", ^{
                        expect(container).to(contain(element));
                    });
                });
            });
        });

        context(@"matching key containment", ^{
            NSDictionary *container = [NSDictionary dictionaryWithObject:elementCopy forKey:@"aKey"];

            context(@"when matching a specific object", ^{
                context(@"positive match", ^{
                    it(@"should find the specified key", ^{
                        expect(container).to(contain(@"aKey").as_a_key());
                    });
                });

                context(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not contain <aKey> nested as a key", container], ^{
                            expect(container).to_not(contain(@"aKey").nested().as_a_key());
                        });
                    });
                });
            });

            context(@"when matching a class", ^{
                it(@"should find the matching class within the keys", ^{
                    expect(container).to(contain(an_instance_of([@"aKey" class])).as_a_key());
                });
            });
        });

        context(@"matching value containment", ^{
            NSDictionary *container = [NSDictionary dictionaryWithObject:elementCopy forKey:@"aKey"];

            context(@"when matching a specific object", ^{
                context(@"positive match", ^{
                    it(@"should find the specified key", ^{
                        expect(container).to(contain(elementCopy).as_a_value());
                    });
                });

                context(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not contain <%@> nested as a value", container, element], ^{
                            expect(container).to_not(contain(element).nested().as_a_value());
                        });
                    });
                });
            });

            context(@"when matching a class", ^{
                it(@"should find the matching class within the keys", ^{
                    expect(container).to(contain(an_instance_of([elementCopy class])).as_a_value());
                });
            });
        });

        context(@"with invalid modifiers", ^{
            NSDictionary *container = [NSDictionary dictionary];

            it(@"should not allow both the as_a_key() and as_a_value() modifiers together", ^{
                expectExceptionWithReason(@"Unexpected use of 'contain' matcher; use the .as_a_key() or .as_a_value() modifiers, but not both", ^{
                    expect(container).to(contain(@"aKey").as_a_key().as_a_value());
                });
            });
        });
    });

    describe(@"when the container is an NSMutableDictionary", ^{
        context(@"plain containment", ^{
            NSMutableDictionary *container = [NSMutableDictionary dictionary];

            context(@"when matching a specific object", ^{
                it(@"should explode", ^{
                    expectExceptionWithReason(@"Unexpected use of 'contain' matcher with dictionary; use the .as_a_key() or .as_a_value() modifiers", ^{
                        expect(container).to(contain(element));
                    });
                });
            });
        });

        context(@"matching key containment", ^{
            NSDictionary *container = [NSDictionary dictionaryWithObject:elementCopy forKey:@"aKey"];

            context(@"when matching a specific object", ^{
                context(@"positive match", ^{
                    it(@"should find the specified key", ^{
                        expect(container).to(contain(@"aKey").as_a_key());
                    });
                });

                context(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not contain <aKey> nested as a key", container], ^{
                            expect(container).to_not(contain(@"aKey").nested().as_a_key());
                        });
                    });
                });
            });

            context(@"when matching a class", ^{
                it(@"should find the matching class within the keys", ^{
                    expect(container).to(contain(an_instance_of([@"aKey" class])).as_a_key());
                });
            });
        });

        context(@"matching value containment", ^{
            NSDictionary *container = [NSDictionary dictionaryWithObject:elementCopy forKey:@"aKey"];

            context(@"when matching a specific object", ^{
                context(@"positive match", ^{
                    it(@"should find the specified key", ^{
                        expect(container).to(contain(elementCopy).as_a_value());
                    });
                });

                context(@"negative match", ^{
                    it(@"should fail with a sensible failure message", ^{
                        expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not contain <%@> nested as a value", container, element], ^{
                            expect(container).to_not(contain(element).nested().as_a_value());
                        });
                    });
                });
            });

            context(@"when matching a class", ^{
                it(@"should find the matching class within the keys", ^{
                    expect(container).to(contain(an_instance_of([elementCopy class])).as_a_value());
                });
            });
        });

        context(@"with invalid modifiers", ^{
            NSMutableDictionary *container = [NSMutableDictionary dictionary];

            it(@"should not allow both the as_a_key() and as_a_value() modifiers together", ^{
                expectExceptionWithReason(@"Unexpected use of 'contain' matcher; use the .as_a_key() or .as_a_value() modifiers, but not both", ^{
                    expect(container).to(contain(@"aKey").as_a_key().as_a_value());
                });
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

        describe(@"with modifiers", ^{
            char *container = (char *)"tom and jerry";
            char *element = (char *)"tom";

            it(@"should explode with the 'nested' modifier", ^{
                expectExceptionWithReason(@"Unexpected use of 'nested' modifier on 'contain' matcher with string", ^{
                    expect(container).to(contain(element).nested());
                });
            });

            it(@"should explode with the 'as_a_key' modifier", ^{
                expectExceptionWithReason(@"Unexpected use of the .as_a_key() modifier on the 'contain' matcher without a dictionary", ^{
                    expect(container).to(contain(element).as_a_key());
                });
            });

            it(@"should explode with the 'as_a_value' modifier", ^{
                expectExceptionWithReason(@"Unexpected use of the .as_a_value() modifier on the 'contain' matcher without a dictionary", ^{
                    expect(container).to(contain(element).as_a_value());
                });
            });
        });

        describe(@"matching based on object class", ^{
            char *container = (char *)"foo";

            it(@"should explode", ^{
                expectExceptionWithReason(@"Unexpected use of 'contain' matcher to check for an object in a string", ^{
                    expect(container).to(contain(an_instance_of([NSObject class])));
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

        describe(@"with modifiers", ^{
            const char *container = "tom and jerry";
            const char *element = "tom";

            it(@"should explode with the 'nested' modifier", ^{
                expectExceptionWithReason(@"Unexpected use of 'nested' modifier on 'contain' matcher with string", ^{
                    expect(container).to(contain(element).nested());
                });
            });

            it(@"should explode with the 'as_a_key' modifier", ^{
                expectExceptionWithReason(@"Unexpected use of the .as_a_key() modifier on the 'contain' matcher without a dictionary", ^{
                    expect(container).to(contain(element).as_a_key());
                });
            });

            it(@"should explode with the 'as_a_value' modifier", ^{
                expectExceptionWithReason(@"Unexpected use of the .as_a_value() modifier on the 'contain' matcher without a dictionary", ^{
                    expect(container).to(contain(element).as_a_value());
                });
            });
        });

        describe(@"matching based on object class", ^{
            const char *container = "foo";

            it(@"should explode", ^{
                expectExceptionWithReason(@"Unexpected use of 'contain' matcher to check for an object in a string", ^{
                    expect(container).to(contain(an_instance_of([NSObject class])));
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

        describe(@"with modifiers", ^{
            NSString *container = @"tom and jerry";
            NSString *element = @"tom";

            it(@"should explode with the 'nested' modifier", ^{
                expectExceptionWithReason(@"Unexpected use of 'nested' modifier on 'contain' matcher with string", ^{
                    expect(container).to(contain(element).nested());
                });
            });

            it(@"should explode with the 'as_a_key' modifier", ^{
                expectExceptionWithReason(@"Unexpected use of the .as_a_key() modifier on the 'contain' matcher without a dictionary", ^{
                    expect(container).to(contain(element).as_a_key());
                });
            });

            it(@"should explode with the 'as_a_value' modifier", ^{
                expectExceptionWithReason(@"Unexpected use of the .as_a_value() modifier on the 'contain' matcher without a dictionary", ^{
                    expect(container).to(contain(element).as_a_value());
                });
            });
        });

        describe(@"matching based on object class", ^{
            NSString *container = @"foo";

            it(@"should explode", ^{
                expectExceptionWithReason(@"Unexpected use of 'contain' matcher to check for an object in a string", ^{
                    expect(container).to(contain(an_instance_of([NSObject class])));
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

        describe(@"with modifiers", ^{
            NSMutableString *container = [[@"A string that contains element" mutableCopy] autorelease];

            it(@"should explode with the 'nested' modifier", ^{
                expectExceptionWithReason(@"Unexpected use of 'nested' modifier on 'contain' matcher with string", ^{
                    expect(container).to(contain(element).nested());
                });
            });

            it(@"should explode with the 'as_a_key' modifier", ^{
                expectExceptionWithReason(@"Unexpected use of the .as_a_key() modifier on the 'contain' matcher without a dictionary", ^{
                    expect(container).to(contain(element).as_a_key());
                });
            });

            it(@"should explode with the 'as_a_value' modifier", ^{
                expectExceptionWithReason(@"Unexpected use of the .as_a_value() modifier on the 'contain' matcher without a dictionary", ^{
                    expect(container).to(contain(element).as_a_value());
                });
            });
        });

        describe(@"matching based on object class", ^{
            NSMutableString *container = [@"foo" mutableCopy];

            it(@"should explode", ^{
                expectExceptionWithReason(@"Unexpected use of 'contain' matcher to check for an object in a string", ^{
                    expect(container).to(contain(an_instance_of([NSObject class])));
                });
            });
        });
    });
});

SPEC_END
