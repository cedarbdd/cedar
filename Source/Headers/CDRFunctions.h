#import <Foundation/Foundation.h>

NSArray *CDRReportersFromEnv(const char*defaultReporterClassName);

int CDRRunSpecs();
int CDRRunSpecsWithCustomExampleReporters(NSArray *reporters);
NSArray *CDRShuffleItemsInArrayWithSeed(NSArray *sortedItems, unsigned int seed);
NSArray *CDRReportersToRun();

int runSpecs() __attribute__((deprecated("Please use CDRRunSpecs()")));
int runAllSpecs() __attribute__((deprecated("Please use CDRRunSpecs()")));
int runSpecsWithCustomExampleReporters(NSArray *reporters) __attribute__((deprecated("Please use CDRRunSpecsWithCustomExampleReporters()")));
