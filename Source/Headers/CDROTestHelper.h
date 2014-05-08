#import <Foundation/Foundation.h>

void CDRHijackOCUnitAndXCTestRun(IMP newImplementation);

int CDRRunOCUnitTests(id testProbe);
void CDRHijackOCUnitRun(IMP newImplementation);

int CDRRunXCUnitTests(id testProbe);
void CDRHijackXCUnitRun(IMP newImplementation);

bool CDRIsXCTest();
bool CDRIsOCTest();
