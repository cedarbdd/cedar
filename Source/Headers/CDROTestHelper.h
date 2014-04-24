#import <Foundation/Foundation.h>

int CDRRunOCUnitTests(id testProbe);
void CDRHijackOCUnitRun(IMP newImplementation);

int CDRRunXCUnitTests(id testProbe);
void CDRHijackXCUnitRun(IMP newImplementation);

bool CDRIsXCTest();
bool CDRIsOCTest();
