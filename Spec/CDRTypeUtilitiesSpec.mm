#import "Cedar.h"
#import "CDRTypeUtilities.h"
#import "CDRNil.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CDRTypeUtilitiesSpec)

describe(@"CDRTypeUtilities", ^{
    describe(@"mapping type encodings and bytes to objective-c objects", ^{
        it(@"should return a boxed number for char", ^{
            char c = 'c';
            [CDRTypeUtilities boxedObjectOfBytes:&c ofObjCType:@encode(char)] should equal(@(c));
        });

        it(@"should return a boxed number for int", ^{
            int i = 23456;
            [CDRTypeUtilities boxedObjectOfBytes:(const char *)&i ofObjCType:@encode(int)] should equal(@(i));
        });

        it(@"should return a boxed number for short", ^{
            short i = 4456;
            [CDRTypeUtilities boxedObjectOfBytes:(const char *)&i ofObjCType:@encode(short)] should equal(@(i));
        });

        it(@"should return a boxed number for long", ^{
            long i = 5345;
            [CDRTypeUtilities boxedObjectOfBytes:(const char *)&i ofObjCType:@encode(long)] should equal(@(i));
        });

        it(@"should return a boxed number for a long long", ^{
            long long i = 63453;
            [CDRTypeUtilities boxedObjectOfBytes:(const char *)&i ofObjCType:@encode(long long)] should equal(@(i));
        });

        it(@"should return a boxed number for unsigned char", ^{
            unsigned char c = 'c';
            [CDRTypeUtilities boxedObjectOfBytes:(const char *)&c ofObjCType:@encode(unsigned char)] should equal(@(c));
        });

        it(@"should return a boxed number for unsigned int", ^{
            unsigned int i = 21234;
            [CDRTypeUtilities boxedObjectOfBytes:(const char *)&i ofObjCType:@encode(unsigned int)] should equal(@(i));
        });

        it(@"should return a boxed number for unsigned short", ^{
            unsigned short i = 4456;
            [CDRTypeUtilities boxedObjectOfBytes:(const char *)&i ofObjCType:@encode(unsigned short)] should equal(@(i));
        });

        it(@"should return a boxed nubmer for unsigned long", ^{
            unsigned long long i = 6346;
            [CDRTypeUtilities boxedObjectOfBytes:(const char *)&i ofObjCType:@encode(long long)] should equal(@(i));
        });

        it(@"should return a boxed number for unsigned long long", ^{
            unsigned long long i = 7234;
            [CDRTypeUtilities boxedObjectOfBytes:(const char *)&i ofObjCType:@encode(unsigned long long)] should equal(@(i));
        });

        it(@"should return a boxed number for float", ^{
            float i = 1.5f;
            [CDRTypeUtilities boxedObjectOfBytes:(const char *)&i ofObjCType:@encode(float)] should equal(@(i));
        });

        it(@"should return a boxed number for double", ^{
            double i = 1.5;
            [CDRTypeUtilities boxedObjectOfBytes:(const char *)&i ofObjCType:@encode(double)] should equal(@(i));
        });

        it(@"should return a boxed number for a non-objc bool", ^{
            bool b = true;
            [CDRTypeUtilities boxedObjectOfBytes:(const char *)&b ofObjCType:@encode(bool)] should equal(@(b));
        });

        it(@"should return a NSString for a c string", ^{
            const char *text = "Hello world!";
            [CDRTypeUtilities boxedObjectOfBytes:(const char *)&text ofObjCType:@encode(char *)] should equal(@"Hello world!");
        });

        it(@"should return the objective-c object it was given", ^{
            id foo = @"bar";
            [CDRTypeUtilities boxedObjectOfBytes:(const char *)&foo ofObjCType:@encode(id)] should be_same_instance_as(foo);
        });

        describe(@"given a nil value", ^{
            context(@"typed as an object", ^{
                it(@"should return CDRNil", ^{
                    id nilParam = nil;
                    [CDRTypeUtilities boxedObjectOfBytes:(const char *)&nilParam ofObjCType:@encode(id)] should equal([CDRNil nilObject]);
                });
            });

            context(@"typed as Class", ^{
                it(@"should return CDRNil", ^{
                    Class nilParam = nil;
                    [CDRTypeUtilities boxedObjectOfBytes:(const char *)&nilParam ofObjCType:@encode(Class)] should equal([CDRNil nilObject]);
                });
            });

            context(@"typed as as block", ^{
                it(@"should return CDRNil", ^{
                    void (^nilBlock)(NSString *) = nil;
                    [CDRTypeUtilities boxedObjectOfBytes:(const char *)&nilBlock ofObjCType:@encode(void (^)(NSString *))] should equal([CDRNil nilObject]);
                });
            });

            context(@"typed as a char *", ^{
                it(@"should return CDRNil", ^{
                    char *nilCharPointer = NULL;
                    [CDRTypeUtilities boxedObjectOfBytes:(const char *)&nilCharPointer ofObjCType:@encode(char *)] should equal([CDRNil nilObject]);
                });
            });

            context(@"typed as a const char *", ^{
                it(@"should return CDRNil", ^{
                    const char *foobar = NULL;
                    [CDRTypeUtilities boxedObjectOfBytes:(const char *)&foobar ofObjCType:@encode(const char *)] should equal([CDRNil nilObject]);
                });
            });

            context(@"typed as a SEL", ^{
                it(@"should return CDRNil", ^{
                    SEL mySelector = nil;
                    [CDRTypeUtilities boxedObjectOfBytes:(const char *)&mySelector ofObjCType:@encode(SEL)] should equal([CDRNil nilObject]);
                });
            });

        });

        it(@"should return the class it was given", ^{
            Class aClass = [NSObject class];
            [CDRTypeUtilities boxedObjectOfBytes:(const char *)&aClass ofObjCType:@encode(Class)] should equal(aClass);
        });

        it(@"should return a string for a selector", ^{
            SEL selector = @selector(description);
            [CDRTypeUtilities boxedObjectOfBytes:(const char *)&selector ofObjCType:@encode(SEL)] should equal(NSStringFromSelector(selector));
        });

        it(@"should return the objective-c block it was given", ^{
            void (^aBlock)() = ^{};
            (id)[CDRTypeUtilities boxedObjectOfBytes:(const char *)&aBlock ofObjCType:@encode(void(^)())] should equal((id)aBlock);
        });
        describe(@"given a char *", ^{
            it(@"should return an NSString when given a non-empty char *", ^{
                char *foobar = (char *)"hello world";
                [CDRTypeUtilities boxedObjectOfBytes:(const char *)&foobar ofObjCType:@encode(char *)] should equal(@"hello world");
            });
            it(@"should return an empty NSString when given an empty char *", ^{
                char *foobar = (char *)"";
                [CDRTypeUtilities boxedObjectOfBytes:(const char *)&foobar ofObjCType:@encode(char *)] should equal(@"");
            });
        });

        describe(@"given a const char *", ^{
            it(@"should return a string for a non-empty const char *", ^{
                const char *foobar = "hello world";
                [CDRTypeUtilities boxedObjectOfBytes:(const char *)&foobar ofObjCType:@encode(const char *)] should equal(@"hello world");
            });

            it(@"should return an empty string for an empty const char *", ^{
                const char *foobar = "";
                [CDRTypeUtilities boxedObjectOfBytes:(const char *)&foobar ofObjCType:@encode(const char *)] should equal(@"");
            });
        });

        it(@"should return an NSValue for other Types", ^{
            CGRect r = CGRectMake(1, 2, 3, 4);
            (id)[CDRTypeUtilities boxedObjectOfBytes:(const char *)&r ofObjCType:@encode(CGRect)] should equal([NSValue valueWithBytes:&r objCType:@encode(CGRect)]);
        });
    });

    describe(@"mapping type encodings to type names", ^{
        it(@"should return the type name for 'c'", ^{
            [CDRTypeUtilities typeNameForEncoding:"c"] should equal(@"char");
        });

        it(@"should return the type name for 'i'", ^{
            [CDRTypeUtilities typeNameForEncoding:"i"] should equal(@"int");
        });

        it(@"should return the type name for 's'", ^{
            [CDRTypeUtilities typeNameForEncoding:"s"] should equal(@"short");
        });

        it(@"should return the type name for 'l'", ^{
            [CDRTypeUtilities typeNameForEncoding:"l"] should equal(@"long");
        });

        it(@"should return the type name for 'q'", ^{
            BOOL longMatchesLongLong = (sizeof(long)==sizeof(long long));
            NSString *typeName = longMatchesLongLong ? @"long" : @"long long";
            [CDRTypeUtilities typeNameForEncoding:"q"] should equal(typeName);
        });

        it(@"should return the type name for 'C'", ^{
            [CDRTypeUtilities typeNameForEncoding:"C"] should equal(@"unsigned char");
        });

        it(@"should return the type name for 'I'", ^{
            [CDRTypeUtilities typeNameForEncoding:"I"] should equal(@"unsigned int");
        });

        it(@"should return the type name for 'S'", ^{
            [CDRTypeUtilities typeNameForEncoding:"S"] should equal(@"unsigned short");
        });

        it(@"should return the type name for 'L'", ^{
            [CDRTypeUtilities typeNameForEncoding:"L"] should equal(@"unsigned long");
        });

        it(@"should return the type name for 'Q'", ^{
            BOOL longMatchesLongLong = (sizeof(long)==sizeof(long long));
            NSString *typeName = longMatchesLongLong ? @"unsigned long" : @"unsigned long long";
            [CDRTypeUtilities typeNameForEncoding:"Q"] should equal(typeName);
        });

        it(@"should return the type name for 'f'", ^{
            [CDRTypeUtilities typeNameForEncoding:"f"] should equal(@"float");
        });

        it(@"should return the type name for 'd'", ^{
            [CDRTypeUtilities typeNameForEncoding:"d"] should equal(@"double");
        });

        it(@"should return the type name for 'B'", ^{
            [CDRTypeUtilities typeNameForEncoding:"B"] should equal(@"bool");
        });

        it(@"should return the type name for 'v'", ^{
            [CDRTypeUtilities typeNameForEncoding:"v"] should equal(@"void");
        });

        it(@"should return the type name for '*'", ^{
            [CDRTypeUtilities typeNameForEncoding:"*"] should equal(@"char *");
        });

        it(@"should return the type name for '@'", ^{
            [CDRTypeUtilities typeNameForEncoding:"@"] should equal(@"id");
        });

        it(@"should return the type name for '#'", ^{
            [CDRTypeUtilities typeNameForEncoding:"#"] should equal(@"Class");
        });

        it(@"should return the type name for ':'", ^{
            [CDRTypeUtilities typeNameForEncoding:":"] should equal(@"SEL");
        });

        it(@"should return the type name for '@?'", ^{
            [CDRTypeUtilities typeNameForEncoding:"@?"] should equal(@"<a block>");
        });

        it(@"should return the type name for '?'", ^{
            [CDRTypeUtilities typeNameForEncoding:"?"] should equal(@"<unknown type>");
        });

        context(@"for structs", ^{
            /*
            struct a_tagged_struct { int a; };
            typedef struct { int a; } an_untagged_struct;
             */

            it(@"should return the type name for '{a_tagged_struct=i}'", ^{
                [CDRTypeUtilities typeNameForEncoding:"{a_tagged_struct=i}"] should equal(@"struct a_tagged_struct");
            });

            it(@"should return the type name for '{?=i}'", ^{
                [CDRTypeUtilities typeNameForEncoding:"{?=i}"] should equal(@"untagged struct");
            });
        });

        context(@"for unions", ^{
            /*
            union a_tagged_union { int a; };
            typedef union { int a; } an_untagged_union;
             */

            it(@"should return the type name for '(a_tagged_union=i)'", ^{

                [CDRTypeUtilities typeNameForEncoding:"(a_tagged_union=i)"] should equal(@"union a_tagged_union");
            });

            it(@"should return the type name for '(?=i)'", ^{
                [CDRTypeUtilities typeNameForEncoding:"(?=i)"] should equal(@"untagged union");
            });
        });

        context(@"for arrays", ^{
            it(@"should return the type name for '[2i]'", ^{
                [CDRTypeUtilities typeNameForEncoding:"[2i]"] should equal(@"int[2]");
            });

            it(@"should return the type name for '[2@?]'", ^{
                [CDRTypeUtilities typeNameForEncoding:"[2@?]"] should equal(@"<a block>[2]");
            });

            it(@"should return the type name for '[2{a_tagged_struct=i}]'", ^{
                [CDRTypeUtilities typeNameForEncoding:"[2{a_tagged_struct=i}]"] should equal(@"struct a_tagged_struct[2]");
            });
        });

        context(@"for pointers", ^{
            it(@"should return the type name for '^i'", ^{
                [CDRTypeUtilities typeNameForEncoding:"^i"] should equal(@"int *");
            });

            it(@"should return the type name for '^@'", ^{
                [CDRTypeUtilities typeNameForEncoding:"^@"] should equal(@"id *");
            });

            it(@"should return the type name for '^^i'", ^{
                [CDRTypeUtilities typeNameForEncoding:"^^i"] should equal(@"int **");
            });

            it(@"should return the type name for '^{a_tagged_struct=i}'", ^{
                [CDRTypeUtilities typeNameForEncoding:"^{a_tagged_struct=i}"] should equal(@"struct a_tagged_struct *");
            });

            it(@"should return the type name for '^i'", ^{
                [CDRTypeUtilities typeNameForEncoding:"^i"] should equal(@"int *");
            });

            it(@"should return the type name for '^*'", ^{
                [CDRTypeUtilities typeNameForEncoding:"^*"] should equal(@"char **");
            });
        });

        context(@"with modifiers", ^{
            it(@"should return the type name for 'r^i'", ^{
                [CDRTypeUtilities typeNameForEncoding:"r^i"] should equal(@"const int *");
            });

            it(@"should return the type name for 'n^i'", ^{
                [CDRTypeUtilities typeNameForEncoding:"n^i"] should equal(@"in int *");
            });

            it(@"should return the type name for 'N^i'", ^{
                [CDRTypeUtilities typeNameForEncoding:"N^i"] should equal(@"inout int *");
            });

            it(@"should return the type name for 'o^i'", ^{
                [CDRTypeUtilities typeNameForEncoding:"o^i"] should equal(@"out int *");
            });

            it(@"should return the type name for 'O^i'", ^{
                [CDRTypeUtilities typeNameForEncoding:"O^i"] should equal(@"bycopy int *");
            });

            it(@"should return the type name for 'R^i'", ^{
                [CDRTypeUtilities typeNameForEncoding:"R^i"] should equal(@"byref int *");
            });

            it(@"should return the type name for 'V^i'", ^{
                [CDRTypeUtilities typeNameForEncoding:"V^i"] should equal(@"oneway int *");
            });

            it(@"should return the type name for 'RVr^i'", ^{
                [CDRTypeUtilities typeNameForEncoding:"RVr^i"] should equal(@"byref oneway const int *");
            });
        });
    });
});

SPEC_END
