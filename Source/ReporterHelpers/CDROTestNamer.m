#import "CDROTestNamer.h"
#import "CDRExample.h"
#import "CDRExampleBase.h"

@interface CDROTestNamer ()
@property (nonatomic, retain) NSMutableCharacterSet *allowedCharacterSet;
@property (nonatomic, retain) NSMutableSet *unavailableNamesForClasses;
@end


@implementation CDROTestNamer

- (void)dealloc {
    self.unavailableNamesForClasses = nil;
    self.allowedCharacterSet = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        self.unavailableNamesForClasses = [NSMutableSet set];
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

- (NSString *)methodNameForExample:(CDRExampleBase *)example withClassName:(NSString *)className {
    NSMutableArray *fullTextPieces = [example.fullTextInPieces mutableCopy];
    NSString *specClassName = [self sanitizeNameFromString:className];
    NSString *firstPieceWithSpecPostfix = [NSString stringWithFormat:@"%@Spec", [fullTextPieces objectAtIndex:0]];
    if ([firstPieceWithSpecPostfix isEqual:specClassName]) {
        [fullTextPieces removeObjectAtIndex:0];
    }

    NSString *methodName = [fullTextPieces componentsJoinedByString:@"_"];
    [fullTextPieces release];
    NSString *sanitizedPotentialName = [self sanitizeNameFromString:methodName];

    NSString *sanitizedName = sanitizedPotentialName;
    NSUInteger i = 0;
    while ([self.unavailableNamesForClasses containsObject:[self fullNameWithClassName:className methodName:sanitizedName]]) {
        i++;
        sanitizedName = [sanitizedPotentialName stringByAppendingFormat:@"_%lu", (unsigned long)i];
    }
    [self.unavailableNamesForClasses addObject:[self fullNameWithClassName:className methodName:sanitizedName]];

    return sanitizedName;
}

- (NSString *)methodNameForExample:(CDRExampleBase *)example {
    return [self methodNameForExample:example withClassName:[self classNameForExample:example]];
}

#pragma mark - Private

- (NSString *)fullNameWithClassName:(NSString *)className methodName:(NSString *)methodName {
    return [NSString stringWithFormat:@"%@ %@", className, methodName];
}

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

@end
