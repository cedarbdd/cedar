#import "CDROTestNamer.h"
#import "CDRExample.h"
#import "CDRExampleBase.h"

@implementation CDROTestNamer

- (NSString *)classNameForExample:(CDRExampleBase *)example {
    NSString *className = NSStringFromClass([example.spec class]);
    return [self sanitizeNameFromString:className];
}

- (NSString *)methodNameForExample:(CDRExampleBase *)example {
    NSMutableArray *fullTextPieces = [example.fullTextInPieces mutableCopy];
    NSString *specClassName = [self classNameForExample:example];
    NSString *firstPieceWithSpecPostfix = [NSString stringWithFormat:@"%@Spec", [fullTextPieces objectAtIndex:0]];
    if ([firstPieceWithSpecPostfix isEqual:specClassName]) {
        [fullTextPieces removeObjectAtIndex:0];
    }

    NSString *methodName = [fullTextPieces componentsJoinedByString:@"_"];
    return [self sanitizeNameFromString:methodName];
}

#pragma mark - Private

- (NSString *)sanitizeNameFromString:(NSString *)string {
    NSMutableString *mutableString = [string mutableCopy];
    [mutableString replaceOccurrencesOfString:@" " withString:@"_" options:0 range:NSMakeRange(0, mutableString.length)];

    NSMutableCharacterSet *allowedCharacterSet = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
    [allowedCharacterSet addCharactersInString:@"_"];

    for (NSUInteger i=0; i<mutableString.length; i++) {
        if (![allowedCharacterSet characterIsMember:[mutableString characterAtIndex:i]]) {
            [mutableString deleteCharactersInRange:NSMakeRange(i, 1)];
            i--;
        }
    }
    return mutableString;
}

@end
