#import <Foundation/Foundation.h>

@protocol CDRExampleReporter;

Class CDRReporterClassFromEnv(const char *defaultReporterClassName);

int runSpecs();
int runAllSpecs() __attribute__((deprecated));
int runSpecsWithCustomExampleReporter(id<CDRExampleReporter> runner);
NSArray *specClassesToRun();
