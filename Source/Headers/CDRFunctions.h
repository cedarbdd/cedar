#import <Foundation/Foundation.h>

NSArray *CDRReportersFromEnv(const char*defaultReporterClassName);

int runSpecs();
int runAllSpecs() __attribute__((deprecated("Please use runSpecs()")));
int runSpecsWithCustomExampleReporters(NSArray *reporters);
NSArray *specClassesToRun();
