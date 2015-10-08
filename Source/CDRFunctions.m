#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "CDRSpec.h"
#import "CDRExampleGroup.h"
#import "CDRExampleReporter.h"
#import "CDRDefaultReporter.h"
#import "CDRSpecHelper.h"
#import "CDRFunctions.h"
#import "CDRReportDispatcher.h"
#import "CDROTestNamer.h"
#import "CDRVersion.h"
#import "CDRSpecRun.h"

static NSString * const CDRBuildVersionKey = @"CDRBuildVersionSHA";

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

void CDREnumerateClasses(void (^block)(Class class, BOOL *stop)) {
    unsigned int numberOfClasses = objc_getClassList(NULL, 0);
    Class classes[numberOfClasses];
    numberOfClasses = objc_getClassList(classes, numberOfClasses);

    BOOL stop = NO;
    for (unsigned int i = 0; i < numberOfClasses && !stop; ++i) {
        block(classes[i], &stop);
    }
}

NSArray *CDRSelectClasses(BOOL (^classSelectionPredicate)(Class class)) {
    NSMutableArray *selectedClasses = [NSMutableArray array];

    CDREnumerateClasses(^(Class class, BOOL *stop) {
        if (classSelectionPredicate(class)) {
            [class retain];
            [selectedClasses addObject:class];
            [class release];
        }
    });
    return selectedClasses;
}

Class CDRFirstOfClasses(BOOL (^classSelectionPredicate)(Class class)) {
    __block Class firstClass = Nil;

    CDREnumerateClasses(^(Class class, BOOL *stop) {
        if (classSelectionPredicate(class)) {
            firstClass = class;
            *stop = YES;
        }
    });

    return firstClass;
}

NSString *CDRVersionString() {
    NSString *releaseVersion = nil, *versionDetails = nil;

    releaseVersion = CDRVersion;
#if COCOAPODS
    versionDetails = @"from CocoaPods";
#endif

    if (!versionDetails) {
        NSBundle *cedarFrameworkBundle = [NSBundle bundleForClass:[CDRSpec class]];
        versionDetails = [cedarFrameworkBundle objectForInfoDictionaryKey:CDRBuildVersionKey];
    }

    return versionDetails ? [CDRVersion stringByAppendingFormat:@" (%@)", versionDetails] : CDRVersion;
}

BOOL (^CDRClassIsSpecPredicate)(Class class) = ^(Class class) {
    return CDRClassIsOfType(class, "CDRSpec");
};

NSBundle *CDRBundleContainingSpecs() {
    Class specClass = CDRFirstOfClasses(CDRClassIsSpecPredicate);
    return [NSBundle bundleForClass:specClass ?: [CDRSpec class]];
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
    const char *className = class_getName(class);
    if (strcmp("UIAccessibilitySafeCategory__NSObject", className) &&
        strcmp("SCRCException", className)) {
        return !!class_getClassMethod(class, selector);
    }
    return NO;
}

void CDRDefineGlobalBeforeAndAfterEachBlocks() {
    [CDRSpecHelper specHelper].globalBeforeEachClasses = CDRSelectClasses(^BOOL(Class class) {
        return CDRClassHasClassMethod(class, @selector(beforeEach));
    });

    [CDRSpecHelper specHelper].globalAfterEachClasses = CDRSelectClasses(^BOOL(Class class) {
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
        id<CDRExampleReporter> reporter = nil;
        if ([reporterClass instancesRespondToSelector:@selector(initWithCedarVersion:)]) {
            reporter = [[[reporterClass alloc] initWithCedarVersion:CDRVersionString()] autorelease];
        } else {
            reporter = [[[reporterClass alloc] init] autorelease];
        }
        [reporters addObject:reporter];
    }
    return reporters;
}

#pragma mark - Spec running

void CDRSuppressStandardPipesWhileLoadingClasses() {
    if (getenv("CEDAR_VERBOSE")) {
        int saved_stdout = dup(STDOUT_FILENO);
        int saved_stderr = dup(STDERR_FILENO);
        freopen("/dev/null", "w", stdout);
        freopen("/dev/null", "w", stderr);

        unsigned int count = 0;
        Class *classes = objc_copyClassList(&count);
        for (int i = 0; i < count; i++) {
            if (class_respondsToSelector(classes[i], @selector(initialize))) {
                [classes[i] class];
            }
        }
        free(classes);

        dup2(saved_stdout, STDOUT_FILENO);
        dup2(saved_stderr, STDERR_FILENO);
    }
}

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

    return CDRSelectClasses(CDRClassIsSpecPredicate);
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
        CDRSpecHelper.specHelper.shouldOnlyRunFocused |= spec.rootGroup.hasFocusedExamples;
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
        CDRSpecHelper.specHelper.shouldOnlyRunFocused |= spec.rootGroup.hasFocusedExamples;
    }
}

NSArray *CDRShuffleItemsInArrayWithSeed(NSArray *sortedItems, unsigned int seed) {
    NSMutableArray *shuffledItems = [sortedItems mutableCopy];
    srand(seed);

    for (int i=0; i < shuffledItems.count; i++) {
        NSUInteger idx = rand() % shuffledItems.count;
        [shuffledItems exchangeObjectAtIndex:i withObjectAtIndex:idx];
    }
    return [shuffledItems autorelease];
}

NSArray *CDRPermuteSpecClassesWithSeed(NSArray *unsortedSpecClasses, unsigned int seed) {
    NSMutableArray *sortedSpecClasses = unsortedSpecClasses.mutableCopy;

    [sortedSpecClasses sortUsingComparator:^NSComparisonResult(Class class1, Class class2) {
        return [NSStringFromClass(class1) compare:NSStringFromClass(class2)];
    }];

    return CDRShuffleItemsInArrayWithSeed(sortedSpecClasses, seed);
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

int CDRRunSpecsWithCustomExampleReporters(NSArray *reporters) {
    @autoreleasepool {
        CDRSpecRun *run = [[CDRSpecRun alloc] initWithExampleReporters:reporters];

        int result = [run performSpecRun:^{
            [run.rootGroups makeObjectsPerformSelector:@selector(runWithDispatcher:) withObject:run.dispatcher];
        }];

        [run release];

        __gcov_flush();

        return result;
    }
}

NSArray *CDRReportersToRun() {
    const char *defaultReporterClassName = "CDRDefaultReporter";
    BOOL isTestBundle = objc_getClass("SenTestProbe") || objc_getClass("XCTestProbe");
    if (isTestBundle) {
        // Cedar for Test Bundles hooks into XCTest's test reporting system.
        defaultReporterClassName = "CDRBufferedDefaultReporter";
    }
    return CDRReportersFromEnv(defaultReporterClassName);
}

int CDRRunSpecs() {
    @autoreleasepool {
        NSArray *reporters = CDRReportersToRun();
        if (![reporters count]) {
            return -999;
        } else {
            return CDRRunSpecsWithCustomExampleReporters(reporters);
        }
    }
}

NSString *CDRGetTestBundleExtension() {
    NSString *extension = nil;;
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    NSSet *xctestFlags = [NSSet setWithArray:@[@"-XCTest", @"-XCTestScopeFile"]];
    if ([xctestFlags intersectsSet:[NSSet setWithArray:arguments]]) {
        extension = @".xctest";
    } else if ([arguments containsObject:@"-SenTest"]) {
        extension = @".octest";
    } else if ((BOOL)NSClassFromString(@"XCTestCase")) {
        extension = @".xctest";
    }

    return extension;
}
