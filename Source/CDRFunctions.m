#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "CDRSpec.h"
#import "CDRExampleGroup.h"
#import "CDRExampleReporter.h"
#import "CDRDefaultReporter.h"
#import "SpecHelper.h"
#import "CDRFunctions.h"
#import "CDRReportDispatcher.h"
#import "CDROTestNamer.h"

#pragma mark - Helpers

BOOL CDRClassIsOfType(Class class, const char * const className) {
    Protocol * protocol = NSProtocolFromString([NSString stringWithCString:className encoding:NSUTF8StringEncoding]);
    if (strcmp(className, class_getName(class))) {
        while (class) {
            if (class_conformsToProtocol(class, protocol)) {
                return YES;
            }
            class = class_getSuperclass(class);
        }
    }

    return NO;
}

NSArray *CDRSelectClasses(BOOL (^classSelectionPredicate)(Class class)) {
    unsigned int numberOfClasses = objc_getClassList(NULL, 0);
    Class classes[numberOfClasses];
    numberOfClasses = objc_getClassList(classes, numberOfClasses);

    NSMutableArray *selectedClasses = [NSMutableArray array];
    for (unsigned int i = 0; i < numberOfClasses; ++i) {
        Class class = classes[i];

        if (classSelectionPredicate(class)) {
            [class retain];
            [selectedClasses addObject:class];
            [class release];
        }
    }
    return selectedClasses;
}

#pragma mark - Globals

void CDRDefineSharedExampleGroups() {
    NSArray *sharedExampleGroupPoolClasses = CDRSelectClasses(^(Class class) {
        return CDRClassIsOfType(class, "CDRSharedExampleGroupPool");
    });

    for (Class class in sharedExampleGroupPoolClasses) {
        CDRSharedExampleGroupPool *sharedExampleGroupPool = [[class alloc] init];
        [sharedExampleGroupPool declareSharedExampleGroups];
        [sharedExampleGroupPool release];
    }
}

BOOL CDRClassHasClassMethod(Class class, SEL selector) {
    if (strcmp("UIAccessibilitySafeCategory__NSObject", class_getName(class))) {
        return !!class_getClassMethod(class, selector);
    }
    return NO;
}

void CDRDefineGlobalBeforeAndAfterEachBlocks() {
    [SpecHelper specHelper].globalBeforeEachClasses = CDRSelectClasses(^BOOL(Class class) {
        return CDRClassHasClassMethod(class, @selector(beforeEach));
    });

    [SpecHelper specHelper].globalAfterEachClasses = CDRSelectClasses(^BOOL(Class class) {
        return CDRClassHasClassMethod(class, @selector(afterEach));
    });
}

#pragma mark - Reporters

NSArray *CDRReporterClassesFromEnv(const char *defaultReporterClassName) {
    const char *reporterClassNamesCsv = getenv("CEDAR_REPORTER_CLASS");
    if (!reporterClassNamesCsv) {
        reporterClassNamesCsv = defaultReporterClassName;
    }

    NSString *objCClassNames = [NSString stringWithUTF8String:reporterClassNamesCsv];
    NSArray *reporterClassNames = [objCClassNames componentsSeparatedByString:@","];

    NSMutableArray *reporterClasses = [NSMutableArray arrayWithCapacity:[reporterClassNames count]];
    for (NSString *reporterClassName in reporterClassNames) {
        Class reporterClass = [NSClassFromString(reporterClassName) retain];
        if (!reporterClass) {
            printf("***** The specified reporter class \"%s\" does not exist. *****\n", [reporterClassName cStringUsingEncoding:NSUTF8StringEncoding]);
            return nil;
        }
        [reporterClasses addObject:reporterClass];
        [reporterClass release];
    }
    return reporterClasses;
}

NSArray *CDRReportersFromEnv(const char *defaultReporterClassName) {
    NSArray *reporterClasses = CDRReporterClassesFromEnv(defaultReporterClassName);

    NSMutableArray *reporters = [NSMutableArray arrayWithCapacity:reporterClasses.count];
    for (Class reporterClass in reporterClasses) {
        [reporters addObject:[[[reporterClass alloc] init] autorelease]];
    }
    return reporters;
}

#pragma mark - Spec running

NSArray *CDRSpecClassesToRun() {
    char *envSpecClassNames = getenv("CEDAR_SPEC_CLASSES");
    if (envSpecClassNames) {
        NSArray *specClassNames =
            [[NSString stringWithUTF8String:envSpecClassNames]
                componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSMutableArray *specClassesToRun = [NSMutableArray arrayWithCapacity:specClassNames.count];

        for (NSString *className in specClassNames) {
            Class specClass = NSClassFromString(className);
            if (specClass) {
                [specClassesToRun addObject:specClass];
            }
        }
        return [[specClassesToRun copy] autorelease];
    }

    return CDRSelectClasses(^(Class class) {
        return CDRClassIsOfType(class, "CDRSpec");
    });
}

NSArray *CDRSpecsFromSpecClasses(NSArray *specClasses) {
    NSMutableArray *specs = [NSMutableArray arrayWithCapacity:specClasses.count];
    for (Class class in specClasses) {
        CDRSpec *spec = [[class alloc] init];
        [spec defineBehaviors];
        [specs addObject:spec];
        [spec release];
    }
    return specs;
}

void CDRMarkFocusedExamplesInSpecs(NSArray *specs) {
    char *envSpecFile = getenv("CEDAR_SPEC_FILE");
    if (envSpecFile) {
        NSArray *components = [[NSString stringWithUTF8String:envSpecFile] componentsSeparatedByString:@":"];

        for (CDRSpec *spec in specs) {
            if ([spec.fileName isEqualToString:[components objectAtIndex:0]]) {
                [spec markAsFocusedClosestToLineNumber:[[components objectAtIndex:1] intValue]];
            }
        }
    }

    for (CDRSpec *spec in specs) {
        SpecHelper.specHelper.shouldOnlyRunFocused |= spec.rootGroup.hasFocusedExamples;
    }
}

void CDRMarkXcodeFocusedExamplesInSpecs(NSArray *specs, NSArray *arguments) {
    // Xcode gives us this:
    //   App ...  -SenTest All TestBundle.xctest
    // when not focused and
    //   App ... -SenTest <SpecClass>/<TestMethod>,<SpecClass>/<TestMethod> TestBundle.xctest
    // when focused in the arguments list.
    //
    // The list defaults to the tests to focused UNLESS "-SenTestInvertScope YES" is
    // provided, in which case the tests provided should be excluded from running.
    NSUInteger index = [arguments indexOfObject:@"-SenTest"];
    if (index == NSNotFound) {
        return;
    }

    NSString *examplesArgument = [arguments objectAtIndex:index + 1];

    BOOL isExclusive = NO;
    index = [arguments indexOfObject:@"-SenTestInvertScope"];
    if (index != NSNotFound) {
        isExclusive = [@"YES" isEqual:[arguments objectAtIndex:index + 1]];
    }

    // TODO: should we handle the InvertScope + All case?
    if ([@[@"Self", @"All"] containsObject:examplesArgument]) {
        return;
    }

    NSMutableDictionary *testMethodNamesBySpecClass = [NSMutableDictionary dictionary];
    for (NSString *testName in [examplesArgument componentsSeparatedByString:@","]) {
        NSArray *components = [testName componentsSeparatedByString:@"/"];
        if (components.count > 1) {
            NSString *specClass = [components objectAtIndex:0];
            NSString *testMethod = [components objectAtIndex:1];

            NSMutableSet *testMethods = [testMethodNamesBySpecClass objectForKey:specClass];
            if (!testMethods) {
                testMethods = [NSMutableSet set];
                [testMethodNamesBySpecClass setObject:testMethods forKey:specClass];
            }
            [testMethods addObject:testMethod];
        }
    }

    CDROTestNamer *testNamer = [[CDROTestNamer alloc] init];

    for (CDRSpec *spec in specs) {
        NSSet *methods = [testMethodNamesBySpecClass objectForKey:NSStringFromClass([spec class])];

        for (CDRExampleBase *example in [spec allChildren]) {
            if (example.hasChildren) {
                continue;
            }

            example.focused = (isExclusive != [methods containsObject:[testNamer methodNameForExample:example]]);
        }
    }

    [testNamer release];

    for (CDRSpec *spec in specs) {
        SpecHelper.specHelper.shouldOnlyRunFocused |= spec.rootGroup.hasFocusedExamples;
    }
}

NSArray *CDRRootGroupsFromSpecs(NSArray *specs) {
    NSMutableArray *groups = [NSMutableArray arrayWithCapacity:specs.count];
    for (CDRSpec *spec in specs) {
        [groups addObject:spec.rootGroup];
    }
    return groups;
}

NSArray *CDRPermuteSpecClassesWithSeed(NSArray *unsortedSpecClasses, unsigned int seed) {
    NSMutableArray *permutedSpecClasses = unsortedSpecClasses.mutableCopy;

    [permutedSpecClasses sortUsingComparator:^NSComparisonResult(Class class1, Class class2) {
        return [NSStringFromClass(class1) compare:NSStringFromClass(class2)];
    }];

    srand(seed);

    for (int i=0; i < permutedSpecClasses.count; i++) {
        NSUInteger idx = rand() % permutedSpecClasses.count;
        [permutedSpecClasses exchangeObjectAtIndex:i withObjectAtIndex:idx];
    }
    return [permutedSpecClasses autorelease];
}

unsigned int CDRGetRandomSeed() {
    unsigned int seed = time(NULL) % 100000 + 2;
    if (getenv("CEDAR_RANDOM_SEED")) {
        seed = [[NSString stringWithUTF8String:getenv("CEDAR_RANDOM_SEED")] intValue];
    }
    return seed;
}

void __attribute__((weak)) __gcov_flush(void) {
}

int runSpecsWithCustomExampleReporters(NSArray *reporters) {
    @autoreleasepool {
        CDRDefineSharedExampleGroups();
        CDRDefineGlobalBeforeAndAfterEachBlocks();

        unsigned int seed = CDRGetRandomSeed();

        NSArray *specClasses = CDRSpecClassesToRun();
        NSArray *permutedSpecClasses = CDRPermuteSpecClassesWithSeed(specClasses, seed);
        NSArray *specs = CDRSpecsFromSpecClasses(permutedSpecClasses);
        CDRMarkFocusedExamplesInSpecs(specs);
        CDRMarkXcodeFocusedExamplesInSpecs(specs, [[NSProcessInfo processInfo] arguments]);

        CDRReportDispatcher *dispatcher = [[CDRReportDispatcher alloc] initWithReporters:reporters];

        NSArray *groups = CDRRootGroupsFromSpecs(specs);
        [dispatcher runWillStartWithGroups:groups andRandomSeed:seed];

        [groups makeObjectsPerformSelector:@selector(runWithDispatcher:) withObject:dispatcher];

        [dispatcher runDidComplete];
        int result = [dispatcher result];

        [dispatcher release];

        __gcov_flush();

        return result;
    }
}

int runSpecs() {
    @autoreleasepool {
        NSArray *reporters = CDRReportersFromEnv("CDRDefaultReporter");
        if (![reporters count]) {
            @throw @"No reporters?  WTF?";
        }
        return runSpecsWithCustomExampleReporters(reporters);
    }
}

int runAllSpecs() {
    return runSpecs();
}
