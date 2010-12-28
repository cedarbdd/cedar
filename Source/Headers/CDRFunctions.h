#import <Foundation/Foundation.h>

@protocol CDRExampleReporter;

int runSpecsWithCustomExampleReporter(NSArray *specClasses, id<CDRExampleReporter> runner);
int runAllSpecs(void);
int runAllSpecsWithCustomExampleReporter(id<CDRExampleReporter> runner);
