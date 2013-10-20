#import <Foundation/Foundation.h>

int CDRRunOCUnitTests(id self, SEL _cmd, id ignored);
void CDRHijackOCUnitRun(IMP newImplementation);

int CDRRunXCUnitTests(id self, SEL _cmd, id ignored);
void CDRHijackXCUnitRun(IMP newImplementation);
