#import "FibonacciCalculator.h"

@implementation FibonacciCalculator

- (int)computeFibonnaciNumberVeryVerySlowly:(int)n {
    if (n == 0) return 0;
    if (n == 1) return 1;
    return [self computeFibonnaciNumberVeryVerySlowly:n - 1] +
           [self computeFibonnaciNumberVeryVerySlowly:n - 2];
}

- (int)computeFibonnaciNumberVeryVeryQuickly:(int)n {
    return (pow((1 + sqrt(5)) / 2.0, n) - pow((1 - sqrt(5)) / 2.0, n) ) / sqrt(5);
}
@end
