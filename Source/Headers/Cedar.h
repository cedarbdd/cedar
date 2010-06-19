#import <Foundation/Foundation.h>

@protocol CDRExampleRunner;

int runSpecsWithCustomExampleRunner(NSArray *specClasses, id<CDRExampleRunner> runner);
int runAllSpecs();
int runAllSpecsWithCustomExampleRunner(id<CDRExampleRunner> runner);

#if TARGET_OS_IPHONE
#import <Cedar/CedarApplicationDelegate.h>
#import <Cedar/CDRExampleRunnerViewController.h>
#endif
