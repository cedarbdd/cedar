#import <Foundation/Foundation.h>

@protocol CDRExampleReporter;

Class CDRReporterClassFromEnv(const char *defaultReporterClassName);

int runAllSpecs();
int runAllSpecsWithCustomExampleReporter(id<CDRExampleReporter> runner);
int runSpecsWithCustomExampleReporter(NSArray *specClasses, id<CDRExampleReporter> runner);
