#import <Foundation/Foundation.h>

@protocol CDRExampleRunner;

int runSpecsWithCustomExampleRunner(NSArray *specClasses, id<CDRExampleRunner> runner);
int runAllSpecs();
int runAllSpecsWithCustomExampleRunner(id<CDRExampleRunner> runner);
