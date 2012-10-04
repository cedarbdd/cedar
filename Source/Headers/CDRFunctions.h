#import <Foundation/Foundation.h>

#if __cplusplus
extern "C" {
#endif

NSArray *CDRReportersFromEnv(const char*defaultReporterClassName);

int runSpecs();
int runAllSpecs() __attribute__((deprecated));
int runSpecsWithCustomExampleReporters(NSArray *reporters);
NSArray *specClassesToRun();

#if __cplusplus
}
#endif
