#import "CDROTestNamer.h"
#import "CDRExample.h"
#import "CDRExampleBase.h"

@interface CDROTestNamer ()
@property (nonatomic, retain) NSMutableCharacterSet *allowedCharacterSet;
@end


@implementation CDROTestNamer

- (id)init {
    self = [super init];
    if (self) {
        self.allowedCharacterSet = [[[NSCharacterSet alphanumericCharacterSet] mutableCopy] autorelease];
        [self.allowedCharacterSet addCharactersInString:@"_"];
    }
    return self;
}

- (NSString *)classNameForExample:(CDRExampleBase *)example {
    NSString *className = NSStringFromClass([example.spec class]);
    className = className ?: @"Cedar";
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
    [fullTextPieces release];
    return [self sanitizeNameFromString:methodName];
}

#pragma mark - Private

- (NSString *)sanitizeNameFromString:(NSString *)string {
    NSMutableString *mutableString = [string mutableCopy];
    [mutableString replaceOccurrencesOfString:@" " withString:@"_" options:0 range:NSMakeRange(0, mutableString.length)];

    for (NSUInteger i=0; i<mutableString.length; i++) {
        if (![self.allowedCharacterSet characterIsMember:[mutableString characterAtIndex:i]]) {
            [mutableString deleteCharactersInRange:NSMakeRange(i, 1)];
            i--;
        }
    }

    return [mutableString autorelease];
}

- (void)dealloc {
    self.allowedCharacterSet = nil;
    [super dealloc];
}

@end
