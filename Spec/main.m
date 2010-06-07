#import <Cedar/Cedar.h>

int main (int argc, const char *argv[]) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  return runAllSpecs();
  [pool drain];
}
