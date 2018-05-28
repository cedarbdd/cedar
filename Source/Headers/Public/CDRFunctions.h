#import <Foundation/Foundation.h>
#import "CDRNullabilityCompat.h"

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif

NSArray *CDRReportersFromEnv(const char*defaultReporterClassName);

int CDRRunSpecs(void);
OBJC_EXPORT void CDRInjectIntoXCTestRunner(void);
int CDRRunSpecsWithCustomExampleReporters(NSArray *reporters);
NSArray *CDRShuffleItemsInArrayWithSeed(NSArray *sortedItems, unsigned int seed);
NSArray *CDRReportersToRun(void);
NSString *CDRGetTestBundleExtension(void);
void CDRSuppressStandardPipesWhileLoadingClasses(void);

NS_ASSUME_NONNULL_END

#ifdef __cplusplus
}
#endif
