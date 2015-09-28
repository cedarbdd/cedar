#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

    void CDRMarkXcodeFocusedExamplesInSpecs(NSArray *specs, NSArray *arguments);
    void CDRMarkFocusedExamplesInSpecs(NSArray *specs);
    NSArray *CDRSpecsFromSpecClasses(NSArray *specClasses);
    void CDRDefineSharedExampleGroups();
    void CDRDefineGlobalBeforeAndAfterEachBlocks();
    unsigned int CDRGetRandomSeed();
    NSArray *CDRSpecClassesToRun();
    NSArray *CDRRootGroupsFromSpecs(NSArray *specs);
    NSArray *CDRPermuteSpecClassesWithSeed(NSArray *unsortedSpecClasses, unsigned int seed);
    id CDRCreateXCTestSuite();
    NSBundle *CDRBundleContainingSpecs();
#ifdef __cplusplus
}
#endif
