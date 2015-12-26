#import <Foundation/Foundation.h>
#import "CDRNullabilityCompat.h"

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif

NSArray *CDRReportersFromEnv(const char*defaultReporterClassName);

int CDRRunSpecs();
OBJC_EXPORT void CDRInjectIntoXCTestRunner();
int CDRRunSpecsWithCustomExampleReporters(NSArray *reporters);
NSArray *CDRShuffleItemsInArrayWithSeed(NSArray *sortedItems, unsigned int seed);
NSArray *CDRReportersToRun();
NSString *CDRGetTestBundleExtension();
void CDRSuppressStandardPipesWhileLoadingClasses();

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END
