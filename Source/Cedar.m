#import <Foundation/Foundation.h>
#import <objc/objc-runtime.h>
#import "Cedar.h"
#import "CDRSpec.h"
#import "CDRExampleRunner.h"
#import "CDRDefaultRunner.h"

BOOL isASpecClass(Class class) {
  if (strcmp("CDRSpec", class_getName(class))) {
    while (class) {
      if (class_conformsToProtocol(class, NSProtocolFromString(@"CDRSpec"))) {
        return YES;
      }
      class = class_getSuperclass(class);
    }
  }
  
  return NO;
}

NSArray *enumerateSpecClasses() {
  unsigned int numberOfClasses = objc_getClassList(NULL, 0);
  Class classes[numberOfClasses];
  numberOfClasses = objc_getClassList(classes, numberOfClasses);
  
  NSMutableArray *specClasses = [NSMutableArray array];
  for (unsigned int i = 0; i < numberOfClasses; ++i) {
    Class class = classes[i];
    if (isASpecClass(class)) {
      [specClasses addObject:class];
    }
  }
  
  return specClasses;
}

int runSpecs(NSArray *specClasses) {
  id<CDRExampleRunner> runner = [[[CDRDefaultRunner alloc] init] autorelease];
  
  for (Class class in specClasses) {
    CDRSpec *spec = [[class alloc] init];
    [spec defineBehaviors];
    [spec runWithRunner:runner];
    [spec release];
  }
  
  return [runner result];
}

int runAllSpecs() {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  int result = runSpecs(enumerateSpecClasses());
  
  [pool drain];
  return result;
}
