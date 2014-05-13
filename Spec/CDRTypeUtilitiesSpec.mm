#import <Cedar/SpecHelper.h>
#import "CDRTypeUtilities.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CDRTypeUtilitiesSpec)

describe(@"CDRTypeUtilities", ^{
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
