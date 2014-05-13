#import "CDRTypeUtilities.h"

@implementation CDRTypeUtilities

static NSDictionary *typeEncodingMapping;
static NSDictionary *typeEncodingModifiersMapping;
static NSCharacterSet *typeEncodingStringsCharacterSet;
static NSCharacterSet *typeEncodingModifiersCharacterSet;

+ (void)initialize {
    BOOL longIsInt = (sizeof(int)==sizeof(long));

    // See: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
    typeEncodingMapping = [@{ @"c": @"char",
                              @"i": @"int",
                              @"s": @"short",
                              @"l": @"long",
                              @"q": longIsInt ? @"long long" : @"long",
                              @"C": @"unsigned char",
                              @"I": @"unsigned int",
                              @"S": @"unsigned short",
                              @"L": @"unsigned long",
                              @"Q": longIsInt ? @"unsigned long long" : @"unsigned long",
                              @"f": @"float",
                              @"d": @"double",
                              @"B": @"bool",
                              @"v": @"void",
                              @"*": @"char *",
                              @"@": @"id",
                              @"#": @"Class",
                              @":": @"SEL",
                              @"@?": @"<a block>",
                              @"?": @"<unknown type>" } retain];
    typeEncodingModifiersMapping = [@{ @"r": @"const",
                                       @"n": @"in",
                                       @"N": @"inout",
                                       @"o": @"out",
                                       @"O": @"bycopy",
                                       @"R": @"byref",
                                       @"V": @"oneway" } retain];
    typeEncodingStringsCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:[[typeEncodingMapping allKeys] componentsJoinedByString:@""]] retain];
    typeEncodingModifiersCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:[[typeEncodingModifiersMapping allKeys] componentsJoinedByString:@""]] retain];
}

+ (NSString *)typeNameForEncoding:(const char *)encodingStr {
    if (!encodingStr || encodingStr[0] == '\0') { return nil; }

    NSScanner *scanner = [NSScanner scannerWithString:[NSString stringWithUTF8String:encodingStr]];
    NSInteger arraySize = 0;
    NSInteger pointerCount = 0;
    NSString *typeName = nil;
    NSString *modifiers = nil;

    if ([scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"["] intoString:NULL]) {
        [scanner scanInteger:&arraySize];
    }

    modifiers = [self scanTypeEncodingModifiersFromScanner:scanner];

    NSString *pointerModifiers;
    if ([scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"^"] intoString:&pointerModifiers]) {
        pointerCount = [pointerModifiers length];
    }

    typeName = [self scanComplexTypeNameFromScanner:scanner];

    if (!typeName) {
        NSString *baseEncoding;
        if ([scanner scanCharactersFromSet:typeEncodingStringsCharacterSet intoString:&baseEncoding]) {
            typeName = typeEncodingMapping[baseEncoding];
        }
    }

    if (typeName) {
        NSMutableString *fullTypeName = [[typeName mutableCopy] autorelease];

        if (modifiers) {
            [fullTypeName insertString:[modifiers stringByAppendingString:@" "] atIndex:0];
        }

        for (int i=0; i<pointerCount; i++) {
            if (i==0 && ![fullTypeName hasSuffix:@"*"]) {
                [fullTypeName appendString:@" "];
            }
            [fullTypeName appendString:@"*"];
        }

        if (arraySize > 0) {
            [fullTypeName appendFormat:@"[%ld]", (long)arraySize];
        }

        return fullTypeName;
    } else {
        return [NSString stringWithUTF8String:encodingStr];
    }
}

+ (NSString *)scanTypeEncodingModifiersFromScanner:(NSScanner *)scanner {
    NSString *modifiers = nil;

    if ([scanner scanCharactersFromSet:typeEncodingModifiersCharacterSet intoString:&modifiers]) {
        NSMutableArray *modifierNames = [NSMutableArray array];
        [modifiers enumerateSubstringsInRange:NSMakeRange(0, [modifiers length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            NSString *modifierName = typeEncodingModifiersMapping[substring];
            if (modifierName) {
                [modifierNames addObject:modifierName];
            }
        }];
        modifiers = [modifierNames count]>0 ? [modifierNames componentsJoinedByString:@" "] : nil;
    }

    return modifiers;
}

+ (NSString *)scanComplexTypeNameFromScanner:(NSScanner *)scanner {
    NSString *complexTypeIntroducer;
    if ([scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"{("] intoString:&complexTypeIntroducer]) {
        NSString *complexType = [complexTypeIntroducer isEqualToString:@"{"] ? @"struct" : @"union";
        NSString *complexTypeName;
        [scanner scanUpToString:@"=" intoString:&complexTypeName];

        if ([complexTypeName isEqualToString:@"?"]) {
            return [@"untagged " stringByAppendingString:complexType];
        } else {
            return [complexType stringByAppendingFormat:@" %@", complexTypeName];
        }
    }
    return nil;
}

@end
