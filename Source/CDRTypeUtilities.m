#import "CDRTypeUtilities.h"
#import "CDRNil.h"

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

+ (id)boxedObjectOfBytes:(const char *)argBuffer ofObjCType:(const char *)argType {
#define IS_TYPE(TYPE) (strncmp(argType, @encode(TYPE), sizeof(@encode(TYPE))) == 0)
#define CONVERT_TYPE(TYPE) ({TYPE i; \
memcpy(&i, argBuffer, sizeof(TYPE)); \
i;})
    if (IS_TYPE(id)) {
        return CONVERT_TYPE(id) ?: [CDRNil nilObject];
    } else if (IS_TYPE(Class)) {
        return CONVERT_TYPE(Class) ?: [CDRNil nilObject];
    } else if (IS_TYPE(void(^)())) {
        return (id)*((void **)argBuffer) ?: [CDRNil nilObject];
    } else if (IS_TYPE(char *)) {
        BOOL isNotNull = *argBuffer != '\0';
        return isNotNull ? [NSString stringWithUTF8String:*(char **)argBuffer] : [CDRNil nilObject];
    } else if (IS_TYPE(const char *)) {
        BOOL isNotNull = *argBuffer != '\0';
        return isNotNull ? [NSString stringWithUTF8String:*(const char **)argBuffer] : [CDRNil nilObject];
    } else if (IS_TYPE(SEL)) {
        return CONVERT_TYPE(SEL) ? NSStringFromSelector(CONVERT_TYPE(SEL)) : [CDRNil nilObject];
    } else if (IS_TYPE(bool)) {
        return @(CONVERT_TYPE(bool));
    } else if (IS_TYPE(char)) {
        return @(CONVERT_TYPE(char));
    } else if (IS_TYPE(unsigned char)) {
        return @(CONVERT_TYPE(unsigned char));
    } else if (IS_TYPE(short)) {
        return @(CONVERT_TYPE(short));
    } else if (IS_TYPE(unsigned short)) {
        return @(CONVERT_TYPE(unsigned short));
    } else if (IS_TYPE(int)) {
        return @(CONVERT_TYPE(int));
    } else if (IS_TYPE(unsigned int)) {
        return @(CONVERT_TYPE(unsigned int));
    } else if (IS_TYPE(long)) {
        return @(CONVERT_TYPE(long));
    } else if (IS_TYPE(unsigned long)) {
        return @(CONVERT_TYPE(unsigned long));
    } else if (IS_TYPE(unsigned long long)) {
        return @(CONVERT_TYPE(unsigned long long));
    } else if (IS_TYPE(double)) {
        return @(CONVERT_TYPE(double));
    } else if (IS_TYPE(float)) {
        return @(CONVERT_TYPE(float));
    } else {
        return [NSValue valueWithBytes:argBuffer objCType:argType];
    }
#undef RETURN_IF_TYPE
#undef IS_TYPE
}

@end
