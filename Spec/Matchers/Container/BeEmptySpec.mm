#import "Cedar.h"
#import "ExpectFailureWithMessage.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(BeEmptySpec)

describe(@"be_empty matcher", ^{
    describe(@"when the value is an STL vector", ^{
        describe(@"which is empty", ^{
            std::vector<int> container;

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(container).to(be_empty);
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <(\n)> to not be empty", ^{
                        expect(container).to_not(be_empty);
                    });
                });
            });
        });

        describe(@"which is not empty", ^{
            std::vector<int> container(2, 7);

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <(\n    7,\n    7\n)> to be empty", ^{
                        expect(container).to(be_empty);
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    expect(container).to_not(be_empty);
                });
            });
        });
    });

    describe(@"when the value is an STL map", ^{
        describe(@"which is empty", ^{
            std::map<int, int> container;

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(container).to(be_empty);
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <{\n}> to not be empty", ^{
                        expect(container).to_not(be_empty);
                    });
                });
            });
        });

        describe(@"which is not empty", ^{
            std::map<int, int> container;
            container[5] = 6;
            container[7] = 10;

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <{\n    5 = 6;\n    7 = 10;\n}> to be empty", ^{
                        expect(container).to(be_empty);
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    expect(container).to_not(be_empty);
                });
            });
        });
    });

    describe(@"when the value is an STL set", ^{
        describe(@"which is empty", ^{
            std::set<int> container;

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(container).to(be_empty);
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <{(\n)}> to not be empty", ^{
                        expect(container).to_not(be_empty);
                    });
                });
            });
        });

        describe(@"which is not empty", ^{
            std::set<int> container;
            container.insert(5);
            container.insert(7);

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage(@"Expected <{(\n    5,\n    7\n)}> to be empty", ^{
                        expect(container).to(be_empty);
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    expect(container).to_not(be_empty);
                });
            });
        });
    });

    describe(@"when the value is an NSArray", ^{
        describe(@"which is empty", ^{
            NSArray *container = [NSArray array];

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(container).to(be_empty);
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not be empty", container], ^{
                        expect(container).to_not(be_empty);
                    });
                });
            });
        });

        describe(@"which is not empty", ^{
            NSArray *container = [NSArray arrayWithObjects:@"foo", @"bar", nil];

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to be empty", container], ^{
                        expect(container).to(be_empty);
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    expect(container).to_not(be_empty);
                });
            });
        });
    });

    describe(@"when the value is an NSMutableArray", ^{
        describe(@"which is empty", ^{
            NSMutableArray *container = [NSMutableArray array];

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(container).to(be_empty);
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not be empty", container], ^{
                        expect(container).to_not(be_empty);
                    });
                });
            });
        });

        describe(@"which is not empty", ^{
            NSMutableArray *container = [NSMutableArray arrayWithObjects:@"foo", @"bar", nil];

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to be empty", container], ^{
                        expect(container).to(be_empty);
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    expect(container).to_not(be_empty);
                });
            });
        });
    });

    describe(@"when the value is an NSDictionary", ^{
        describe(@"which is empty", ^{
            NSDictionary *container = [NSDictionary dictionary];

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(container).to(be_empty);
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not be empty", container], ^{
                        expect(container).to_not(be_empty);
                    });
                });
            });
        });

        describe(@"which is not empty", ^{
            NSDictionary *container = [NSDictionary dictionaryWithObjectsAndKeys:@"object1", @"key1", @"object2", @"key2", nil];

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to be empty", container], ^{
                        expect(container).to(be_empty);
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    expect(container).to_not(be_empty);
                });
            });
        });
    });

    describe(@"when the value is an NSMutableDictionary", ^{
        describe(@"which is empty", ^{
            NSMutableDictionary *container = [NSMutableDictionary dictionary];

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(container).to(be_empty);
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not be empty", container], ^{
                        expect(container).to_not(be_empty);
                    });
                });
            });
        });

        describe(@"which is not empty", ^{
            NSMutableDictionary *container = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"object1", @"key1", @"object2", @"key2", nil];

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to be empty", container], ^{
                        expect(container).to(be_empty);
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    expect(container).to_not(be_empty);
                });
            });
        });
    });

    describe(@"when the value is an NSSet", ^{
        describe(@"which is empty", ^{
            NSSet *container = [NSSet set];

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(container).to(be_empty);
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not be empty", container], ^{
                        expect(container).to_not(be_empty);
                    });
                });
            });
        });

        describe(@"which is not empty", ^{
            NSSet *container = [NSSet setWithObjects:@"object1", @"object2", nil];

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to be empty", container], ^{
                        expect(container).to(be_empty);
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    expect(container).to_not(be_empty);
                });
            });
        });
    });

    describe(@"when the value is an NSMutableSet", ^{
        describe(@"which is empty", ^{
            NSMutableSet *container = [NSMutableSet set];

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(container).to(be_empty);
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not be empty", container], ^{
                        expect(container).to_not(be_empty);
                    });
                });
            });
        });

        describe(@"which is not empty", ^{
            NSMutableSet *container = [NSMutableSet setWithObjects:@"object1", @"object2", nil];

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to be empty", container], ^{
                        expect(container).to(be_empty);
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    expect(container).to_not(be_empty);
                });
            });
        });
    });

    describe(@"when the value is an NSString", ^{
        describe(@"which is empty", ^{
            NSString *container = [NSString string];

            describe(@"positive match", ^{
                it(@"should should pass", ^{
                    expect(container).to(be_empty);
                });
            });

            describe(@"negative match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to not be empty", container], ^{
                        expect(container).to_not(be_empty);
                    });
                });
            });
        });

        describe(@"which is not empty", ^{
            NSString *container = [NSString stringWithFormat:@"not empty"];

            describe(@"positive match", ^{
                it(@"should fail with a sensible failure message", ^{
                    expectFailureWithMessage([NSString stringWithFormat:@"Expected <%@> to be empty", container], ^{
                        expect(container).to(be_empty);
                    });
                });
            });

            describe(@"negative match", ^{
                it(@"should pass", ^{
                    expect(container).to_not(be_empty);
                });
            });
        });
    });

    describe(@"when the value is nil", ^{
        it(@"should not match, and alert the user the value was nil", ^{
            expectFailureWithMessage(@"Unexpected use of be_empty matcher to check for nil. The actual value was nil. This is probably not what you intended to verify.", ^{
                id myNilValue = nil;
                expect(myNilValue).to(be_empty);
            });
        });
    });
});

describe(@"be_empty shorthand syntax (no parentheses)", ^{
    NSArray *container = [NSArray array];

    describe(@"positive match", ^{
        it(@"should should pass", ^{
            expect(container).to(be_empty);
        });
    });

    describe(@"negative match", ^{
        it(@"should fail with a sensible failure message", ^{
            expectFailureWithMessage(@"Expected <(\n)> to not be empty", ^{
                expect(container).to_not(be_empty);
            });
        });
    });
});

SPEC_END
